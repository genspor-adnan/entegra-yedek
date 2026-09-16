-- 706: DİŞ KLİNİĞİ MODÜLÜ — çekirdek şema.
--
-- Kaynak tasarım `Ekranlar/Dis Klinigi/dis_sureci.html` (süreç + veri modeli)
-- ve yanındaki mockup'lar: hasta kartı (v5: odontogram + tedavi planı tek
-- sekmede), günlük akış, seans kaydı, lab iş emri, ödeme planı.
--
-- TEMEL KARARLAR
--  1. İŞ BİRİMİ TEDAVİ PLANIDIR, muayene değil. Diş hekimliğinde muayene
--     bir kez yapılır, iş aylarca süren bir plan üzerinden yürür: bulgular
--     odontograma işlenir → diş/yüzey bazlı plan satırları fiyatlanır →
--     seanslara bölünür → her seansta yapılan işlem ücretlendirilir. Muayene
--     kaydına ücret yazılsaydı üç seanslık kanal tedavisi ilk gün
--     faturalanırdı.
--  2. ÜCRET İŞLEM ANINDA DOĞAR (seans), plan satırı yalnız ADAYDIR. Plan
--     satırı "yapıldı" işaretlenince başvuruya (belge tür 19) satır düşer.
--     Proforma hastaya gösterilen niyettir, tahakkuk değil.
--  3. ODONTOGRAM ÜÇ KATMANLIDIR (mevcut · planlanan · tamamlanan) ve tek
--     tablodur: aynı kayıt hem anatomik şemayı hem diş tablosunu besler.
--     Yeni durum eskisini pasifleştirir, geçmiş silinmez - "bu diş ne
--     zaman kron oldu" sorusu ancak böyle cevaplanır.
--  4. DİŞ MUAYENESİ genel muayenenin 1:1 UZANTISIDIR (göz modülüyle aynı
--     desen): tanı, e-reçete, e-Nabız ve "Tamamla" Muayene modülünde kalır.
--  5. RANDEVU ÜNİT (koltuk) KAYNAKLIDIR: randevu tablosuna unit_id ve plan
--     satırı bağı eklenir; ayrı bir diş randevu tablosu AÇILMAZ (mockup
--     notu: "bu ekran ayrı randevu takvimi değildir").
--  6. LAB İŞİ TEDARİKÇİ CARİDİR (dis_lab → taraf): lab faturası alış
--     faturasıyla eşlenir, hekim hakedişinden lab maliyeti düşülür.

-- ============================================================ kod listeleri ==
insert into public.kod_liste (kod, ad)
select v.kod, v.ad from (values
    ('dis.durum',        'Diş Durumu (odontogram)'),
    ('dis.katman',       'Odontogram Katmanı'),
    ('dis.kaynak',       'Odontogram Bulgu Kaynağı'),
    ('dis.dentisyon',    'Dentisyon'),
    ('dis.plan_durum',   'Tedavi Planı Durumu'),
    ('dis.satir_durum',  'Plan Satırı Durumu'),
    ('dis.faz',          'Tedavi Planı Fazı'),
    ('dis.ucret_kurali', 'Ücretlendirme Kuralı'),
    ('dis.islem_grubu',  'Diş İşlem Grubu'),
    ('dis.lab_asama',    'Lab İş Emri Aşaması'),
    ('dis.lab_is_turu',  'Lab İş Türü'),
    ('dis.olcu_tipi',    'Ölçü Tipi'),
    ('dis.seans_durum',  'Seans Durumu'),
    ('dis.unit_tur',     'Ünit Türü'),
    ('dis.onam_tur',     'Dental Onam Türü'),
    ('dis.odeme_yontemi','Ödeme Planı Yöntemi')
  ) as v(kod, ad)
 where not exists (select 1 from public.kod_liste k where k.kod = v.kod);

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  join (values
    -- Odontogram durum kodları (mockup: hızlı bulgu paleti + dis_sureci listesi).
    ('dis.durum', 0, 'Sağlam'), ('dis.durum', 1, 'Çürük (başlangıç)'),
    ('dis.durum', 2, 'Çürük (dentin)'), ('dis.durum', 3, 'Çürük (derin)'),
    ('dis.durum', 10, 'Amalgam dolgu'), ('dis.durum', 11, 'Kompozit dolgu'),
    ('dis.durum', 12, 'İnlay / onlay'), ('dis.durum', 20, 'Kanal tedavili'),
    ('dis.durum', 30, 'Kron'), ('dis.durum', 31, 'Köprü ayağı'), ('dis.durum', 32, 'Köprü gövdesi'),
    ('dis.durum', 40, 'İmplant'), ('dis.durum', 50, 'Eksik'), ('dis.durum', 51, 'Çekim endikasyonu'),
    ('dis.durum', 52, 'Gömülü'), ('dis.durum', 60, 'Kırık'), ('dis.durum', 61, 'Aşınma'),
    ('dis.durum', 62, 'Mobil'), ('dis.durum', 70, 'Süt kalıntısı'), ('dis.durum', 71, 'Sürmemiş'),
    ('dis.durum', 80, 'Protez'),
    ('dis.katman', 1, 'Mevcut durum'), ('dis.katman', 2, 'Planlanan'), ('dis.katman', 3, 'Tamamlanan'),
    ('dis.kaynak', 1, 'Muayene'), ('dis.kaynak', 2, 'RVG / panoramik'), ('dis.kaynak', 3, 'Hasta beyanı'),
    ('dis.kaynak', 4, 'Dış kayıt'), ('dis.kaynak', 5, 'Seans'),
    ('dis.dentisyon', 1, 'Daimi'), ('dis.dentisyon', 2, 'Süt'), ('dis.dentisyon', 3, 'Karma'),
    ('dis.plan_durum', 1, 'Taslak'), ('dis.plan_durum', 2, 'Sunuldu'), ('dis.plan_durum', 3, 'Onaylı'),
    ('dis.plan_durum', 4, 'Sürüyor'), ('dis.plan_durum', 5, 'Tamamlandı'), ('dis.plan_durum', 6, 'İptal'),
    ('dis.plan_durum', 7, 'Süresi doldu'),
    ('dis.satir_durum', 1, 'Planlı'), ('dis.satir_durum', 2, 'Sürüyor'), ('dis.satir_durum', 3, 'Yapıldı'),
    ('dis.satir_durum', 4, 'İptal'), ('dis.satir_durum', 5, 'Ertelendi'),
    ('dis.faz', 1, 'Acil / ağrı giderme'), ('dis.faz', 2, 'Restoratif'), ('dis.faz', 3, 'Protetik'),
    ('dis.faz', 4, 'İdame'),
    ('dis.ucret_kurali', 1, 'Tamamlanınca'), ('dis.ucret_kurali', 2, 'Seans başına oran'),
    ('dis.ucret_kurali', 3, 'Adet'),
    ('dis.islem_grubu', 1, 'Restoratif'), ('dis.islem_grubu', 2, 'Endodonti'), ('dis.islem_grubu', 3, 'Protetik'),
    ('dis.islem_grubu', 4, 'Cerrahi'), ('dis.islem_grubu', 5, 'Periodontal'), ('dis.islem_grubu', 6, 'Ortodonti'),
    ('dis.islem_grubu', 7, 'Pedodonti'), ('dis.islem_grubu', 8, 'Estetik'), ('dis.islem_grubu', 9, 'Muayene / görüntüleme'),
    ('dis.lab_asama', 1, 'Ölçü bekliyor'), ('dis.lab_asama', 2, 'Gönderildi'), ('dis.lab_asama', 3, 'Tasarım onayı'),
    ('dis.lab_asama', 4, 'Üretim'), ('dis.lab_asama', 5, 'Geldi'), ('dis.lab_asama', 6, 'Prova'),
    ('dis.lab_asama', 7, 'Geri gönderildi'), ('dis.lab_asama', 8, 'Teslim edildi'), ('dis.lab_asama', 9, 'İptal'),
    ('dis.lab_is_turu', 1, 'Kron'), ('dis.lab_is_turu', 2, 'Köprü'), ('dis.lab_is_turu', 3, 'İmplant üstü'),
    ('dis.lab_is_turu', 4, 'Total protez'), ('dis.lab_is_turu', 5, 'Parsiyel protez'), ('dis.lab_is_turu', 6, 'Ortodonti apareyi'),
    ('dis.lab_is_turu', 7, 'Gece plağı'), ('dis.lab_is_turu', 8, 'Diğer'),
    ('dis.olcu_tipi', 1, 'Geleneksel'), ('dis.olcu_tipi', 2, 'Dijital (STL)'),
    ('dis.seans_durum', 1, 'Açık'), ('dis.seans_durum', 2, 'Bitti'), ('dis.seans_durum', 3, 'İptal'),
    ('dis.unit_tur', 1, 'Genel'), ('dis.unit_tur', 2, 'Cerrahi'), ('dis.unit_tur', 3, 'Hijyen'), ('dis.unit_tur', 4, 'Pedodonti'),
    ('dis.onam_tur', 1, 'Dental genel'), ('dis.onam_tur', 2, 'Kanal tedavisi'), ('dis.onam_tur', 3, 'Çekim / cerrahi'),
    ('dis.onam_tur', 4, 'İmplant'), ('dis.onam_tur', 5, 'Protez'), ('dis.onam_tur', 6, 'Beyazlatma'),
    ('dis.onam_tur', 7, 'Ortodonti'), ('dis.onam_tur', 8, 'Pedodonti (veli)'),
    ('dis.odeme_yontemi', 1, 'Nakit'), ('dis.odeme_yontemi', 2, 'POS taksit'), ('dis.odeme_yontemi', 3, 'Havale'),
    ('dis.odeme_yontemi', 4, 'Kurum')
  ) as v(liste, deger, ad) on v.liste = l.kod
 where not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger);

-- ==================================================================== ünit ==
-- Ünit = koltuk. Randevu ünite verilir (hekim + ünit + süre): iki hekim aynı
--   koltuğu paylaşabilir, bir hekim iki koltukta çalışabilir.
create table if not exists public.dis_unit (
  id             integer generated by default as identity primary key,
  sube_id        integer not null default 0,
  kod            varchar(20)  not null,
  ad             varchar(80)  not null,
  tur            smallint     not null default 1,      -- dis.unit_tur
  varsayilan_hekim_id integer references public.taraf(id),
  demirbas_id    integer references public.demirbas(id),
  depo_id        integer references public.depo(id),   -- sarf hangi depodan düşer
  rvg_cihaz_id   integer references public.radyoloji_cihaz(id),
  aktif          smallint     not null default 1,
  ekleyen        integer not null default 0,
  ekleme_tarihi  timestamptz not null default now(),
  degistiren     integer not null default 0,
  degistirme_tarihi timestamptz
);
create unique index if not exists ux_dis_unit_kod on public.dis_unit (sube_id, kod);
comment on table public.dis_unit is 'Diş ünitesi / koltuk (706): randevu ve seans kaynağı.';

-- ======================================================== diş muayenesi 1:1 ==
create table if not exists public.dis_muayene (
  id                 integer generated by default as identity primary key,
  sube_id            integer not null default 0,
  muayene_id         integer not null references public.muayene(id) on delete cascade,
  hasta_id           integer not null references public.taraf(id),
  dentisyon          smallint not null default 1,        -- dis.dentisyon
  ekstraoral         varchar(600) not null default '',
  intraoral_yumusak  varchar(600) not null default '',
  okluzyon_sinif     smallint not null default 0,        -- 0 -, 1 Angle I, 2 II, 3 III
  overjet_mm         numeric(4,1),
  overbite_mm        numeric(4,1),
  tme_bulgu          varchar(200) not null default '',
  hijyen_durum       varchar(200) not null default '',
  plak_indeksi       numeric(5,2),
  bruksizm           smallint not null default 0,
  sigara             smallint not null default 0,
  agiz_solunumu      smallint not null default 0,
  dmft_d             smallint not null default 0,
  dmft_m             smallint not null default 0,
  dmft_f             smallint not null default 0,
  vitalite_json      jsonb not null default '{}'::jsonb, -- diş → soğuk/perküsyon
  dental_anamnez     varchar(600) not null default '',
  ekleyen            integer not null default 0,
  ekleme_tarihi      timestamptz not null default now(),
  degistiren         integer not null default 0,
  degistirme_tarihi  timestamptz
);
create unique index if not exists ux_dis_muayene_muayene on public.dis_muayene (muayene_id);
create index if not exists ix_dis_muayene_hasta on public.dis_muayene (hasta_id);
comment on table public.dis_muayene is 'Diş muayenesi (706): genel muayenenin 1:1 uzantısı - ağız içi/dışı bulgular, DMFT, oklüzyon.';

-- ============================================================== odontogram ==
-- Satır = (hasta, diş, yüzeyler, durum, katman). Yüzey kodları M D O V L I;
--   birden çok yüzey 'OD' gibi birleşik yazılır (mockup: `yz:{O:'curuk',D:'curuk'}`).
--   `aktif = 0` pasifleşmiş geçmiş durum; şema yalnız aktifleri çizer.
create table if not exists public.dis_odontogram (
  id             integer generated by default as identity primary key,
  sube_id        integer not null default 0,
  hasta_id       integer not null references public.taraf(id),
  dis_no         smallint not null,                 -- FDI: daimi 11-48, süt 51-85; 0 = ağız geneli
  dentisyon      smallint not null default 1,
  yuzeyler       varchar(8) not null default '',    -- '' = tüm diş
  durum_kod      smallint not null default 0,       -- dis.durum
  katman         smallint not null default 1,       -- dis.katman
  kaynak         smallint not null default 1,       -- dis.kaynak
  muayene_id     integer references public.muayene(id),
  seans_id       integer,                           -- fk sonra (dis_seans)
  plan_satir_id  integer,                           -- fk sonra (dis_tedavi_plani_satir)
  tarih          date not null default current_date,
  not_metin      varchar(200) not null default '',
  aktif          smallint not null default 1,
  ekleyen        integer not null default 0,
  ekleme_tarihi  timestamptz not null default now(),
  degistiren     integer not null default 0,
  degistirme_tarihi timestamptz
);
create index if not exists ix_dis_odontogram_hasta on public.dis_odontogram (hasta_id, dis_no, aktif);
comment on table public.dis_odontogram is
  'Odontogram (706): diş × yüzey × durum × katman (1 mevcut · 2 planlanan · 3 tamamlanan). Aynı kayıt anatomik şemayı ve diş tablosunu besler.';

-- ============================================================ periodontal ==
create table if not exists public.dis_periodontal (
  id             integer generated by default as identity primary key,
  sube_id        integer not null default 0,
  hasta_id       integer not null references public.taraf(id),
  muayene_id     integer references public.muayene(id),
  tarih          date not null default current_date,
  olcen_id       integer references public.taraf(id),
  plak_indeksi   numeric(5,2),
  bop_oran       numeric(5,2),
  cep5_sayisi    smallint not null default 0,
  ort_cal        numeric(4,1),
  evre           smallint not null default 0,      -- AAP 2017: 1-4
  derece         varchar(1) not null default '',   -- A/B/C
  not_metin      varchar(300) not null default '',
  ekleyen        integer not null default 0,
  ekleme_tarihi  timestamptz not null default now(),
  degistiren     integer not null default 0,
  degistirme_tarihi timestamptz
);
create index if not exists ix_dis_periodontal_hasta on public.dis_periodontal (hasta_id, tarih desc);

create table if not exists public.dis_periodontal_olcum (
  id             integer generated by default as identity primary key,
  periodontal_id integer not null references public.dis_periodontal(id) on delete cascade,
  dis_no         smallint not null,
  cep_mv smallint, cep_v smallint, cep_dv smallint, cep_ml smallint, cep_l smallint, cep_dl smallint,
  cekilme_v smallint, cekilme_l smallint,
  kanama_v smallint not null default 0, kanama_l smallint not null default 0,
  mobilite       smallint not null default 0,      -- 0-3
  furkasyon      smallint not null default 0,      -- 0-3
  plak           smallint not null default 0,
  ekleyen        integer not null default 0,
  ekleme_tarihi  timestamptz not null default now(),
  degistiren     integer not null default 0,
  degistirme_tarihi timestamptz
);
create unique index if not exists ux_dis_perio_olcum on public.dis_periodontal_olcum (periodontal_id, dis_no);

-- ============================================================ tedavi planı ==
create table if not exists public.dis_tedavi_plani (
  id                 integer generated by default as identity primary key,
  sube_id            integer not null default 0,
  plan_no            varchar(20) not null default '',       -- TP-yyyy/nnnn
  hasta_id           integer not null references public.taraf(id),
  muayene_id         integer references public.muayene(id),
  hekim_id           integer references public.taraf(id),
  varyant            varchar(1) not null default 'A',       -- alternatif plan B
  ana_plan_id        integer references public.dis_tedavi_plani(id),
  fiyat_listesi_id   integer references public.fiyat_listesi(id),
  odeyen_kurum_id    integer references public.taraf(id),
  toplam             numeric(18,2) not null default 0,
  indirim            numeric(18,2) not null default 0,
  net                numeric(18,2) not null default 0,
  odeme_secenegi     varchar(120) not null default '',
  taksit_sayisi      smallint not null default 0,
  proforma_no        varchar(30) not null default '',
  proforma_dokuman_id integer,
  gecerlilik_bitis   date,
  hasta_onay_zamani  timestamptz,
  onay_yontemi       varchar(20) not null default '',       -- tablet / ıslak / portal
  durum              smallint not null default 1,           -- dis.plan_durum
  aciklama           varchar(400) not null default '',
  ekleyen            integer not null default 0,
  ekleme_tarihi      timestamptz not null default now(),
  degistiren         integer not null default 0,
  degistirme_tarihi  timestamptz
);
create index if not exists ix_dis_plan_hasta on public.dis_tedavi_plani (hasta_id, durum);
create unique index if not exists ux_dis_plan_no on public.dis_tedavi_plani (plan_no) where plan_no <> '';
comment on table public.dis_tedavi_plani is 'Tedavi planı (706): iş birimi. Taslak → sunuldu → onaylı → sürüyor → tamamlandı.';

create table if not exists public.dis_tedavi_plani_satir (
  id                 integer generated by default as identity primary key,
  plan_id            integer not null references public.dis_tedavi_plani(id) on delete cascade,
  faz                smallint not null default 2,           -- dis.faz
  sira               smallint not null default 0,
  dis_no             smallint not null default 0,           -- 0 = ağız geneli
  dis_nolar          varchar(120) not null default '',      -- köprü: '24,25,26'
  yuzeyler           varchar(8) not null default '',
  hizmet_id          integer not null references public.hizmet(id),
  hekim_id           integer references public.taraf(id),
  seans_sayisi       smallint not null default 1,
  yapilan_seans      smallint not null default 0,
  liste_fiyat        numeric(18,2) not null default 0,
  iskonto            numeric(18,2) not null default 0,
  net                numeric(18,2) not null default 0,
  kurum_tutar        numeric(18,2) not null default 0,
  hasta_tutar        numeric(18,2) not null default 0,
  ucret_kurali       smallint not null default 1,           -- dis.ucret_kurali
  lab_gerekir        smallint not null default 0,
  lab_isemri_id      integer,                               -- fk sonra
  onam_tur           smallint not null default 0,
  hasta_onayli       smallint not null default 0,
  durum              smallint not null default 1,           -- dis.satir_durum
  tamamlanma         timestamptz,
  aciklama           varchar(300) not null default '',
  sube_id            integer not null default 0,
  ekleyen            integer not null default 0,
  ekleme_tarihi      timestamptz not null default now(),
  degistiren         integer not null default 0,
  degistirme_tarihi  timestamptz
);
create index if not exists ix_dis_plan_satir_plan on public.dis_tedavi_plani_satir (plan_id, faz, sira);
comment on table public.dis_tedavi_plani_satir is
  'Plan satırı (706): diş + yüzey + hizmet + hekim + seans + fiyat. Ücret ADAYIDIR; yapıldı işaretlenince başvuru satırı doğar.';

-- ==================================================================== seans ==
create table if not exists public.dis_seans (
  id                 integer generated by default as identity primary key,
  sube_id            integer not null default 0,
  randevu_id         integer references public.randevu(id),
  belge_id           integer references public.belge(id),  -- başvuru (tür 19)
  hasta_id           integer not null references public.taraf(id),
  hekim_id           integer references public.taraf(id),
  asistan_id         integer references public.taraf(id),
  unit_id            integer references public.dis_unit(id),
  plan_id            integer references public.dis_tedavi_plani(id),
  baslangic          timestamptz not null default now(),
  bitis              timestamptz,
  sure_dk            smallint not null default 0,
  anestezi_tur       varchar(60) not null default '',
  anestezi_ilac      varchar(80) not null default '',
  anestezi_doz       varchar(40) not null default '',
  anestezi_saat      time,
  uygulama_notu      varchar(1000) not null default '',
  komplikasyon       varchar(300) not null default '',
  hastaya_talimat    varchar(400) not null default '',
  sonraki_plan       varchar(300) not null default '',
  sterilizasyon_paket varchar(30) not null default '',
  durum              smallint not null default 1,           -- dis.seans_durum
  ekleyen            integer not null default 0,
  ekleme_tarihi      timestamptz not null default now(),
  degistiren         integer not null default 0,
  degistirme_tarihi  timestamptz
);
create index if not exists ix_dis_seans_hasta on public.dis_seans (hasta_id, baslangic desc);
create index if not exists ix_dis_seans_gun on public.dis_seans (sube_id, baslangic);
comment on table public.dis_seans is 'Seans (706): ünitte geçen bir oturum - randevu + başvuru + plan bağı, ekip, süre.';

create table if not exists public.dis_seans_islem (
  id                 integer generated by default as identity primary key,
  seans_id           integer not null references public.dis_seans(id) on delete cascade,
  plan_satir_id      integer references public.dis_tedavi_plani_satir(id),
  hizmet_id          integer not null references public.hizmet(id),
  dis_no             smallint not null default 0,
  yuzeyler           varchar(8) not null default '',
  seans_no           smallint not null default 1,
  tamamlandi         smallint not null default 0,
  calisma_boyu_json  jsonb not null default '{}'::jsonb,   -- endodonti: kanal → mm
  belge_satir_id     integer references public.belge_satir(id),
  odontogram_id      integer references public.dis_odontogram(id),
  not_metin          varchar(300) not null default '',
  sube_id            integer not null default 0,
  ekleyen            integer not null default 0,
  ekleme_tarihi      timestamptz not null default now(),
  degistiren         integer not null default 0,
  degistirme_tarihi  timestamptz
);
create index if not exists ix_dis_seans_islem_seans on public.dis_seans_islem (seans_id);

create table if not exists public.dis_seans_sarf (
  id                 integer generated by default as identity primary key,
  seans_id           integer not null references public.dis_seans(id) on delete cascade,
  stok_id            integer not null references public.stok(id),
  miktar             numeric(18,3) not null default 1,
  birim              varchar(20) not null default '',
  seri_lot_id        integer,
  kaynak             smallint not null default 1,           -- 1 set · 2 elle · 3 barkod
  maliyet            numeric(18,2) not null default 0,
  sarf_belge_id      integer references public.belge(id),
  sube_id            integer not null default 0,
  ekleyen            integer not null default 0,
  ekleme_tarihi      timestamptz not null default now(),
  degistiren         integer not null default 0,
  degistirme_tarihi  timestamptz
);
create index if not exists ix_dis_seans_sarf_seans on public.dis_seans_sarf (seans_id);

-- İşlem seti: hizmete bağlı standart sarf (kanal tedavisi = eğe + pat + gutta).
create table if not exists public.hizmet_sarf_seti (
  id                 integer generated by default as identity primary key,
  hizmet_id          integer not null references public.hizmet(id) on delete cascade,
  stok_id            integer not null references public.stok(id),
  miktar             numeric(18,3) not null default 1,
  birim              varchar(20) not null default '',
  seans_basi         smallint not null default 1,
  sube_id            integer not null default 0,
  ekleyen            integer not null default 0,
  ekleme_tarihi      timestamptz not null default now(),
  degistiren         integer not null default 0,
  degistirme_tarihi  timestamptz
);
create index if not exists ix_hizmet_sarf_seti_hizmet on public.hizmet_sarf_seti (hizmet_id);

-- ====================================================================== lab ==
create table if not exists public.dis_lab (
  id                 integer generated by default as identity primary key,
  sube_id            integer not null default 0,
  taraf_id           integer not null references public.taraf(id),   -- tedarikçi cari
  ad                 varchar(120) not null,
  dijital            smallint not null default 0,
  portal_adres       varchar(200) not null default '',
  sla_gun            smallint not null default 7,
  fiyat_listesi_id   integer references public.fiyat_listesi(id),
  kurye_gunleri      varchar(40) not null default '',
  aktif              smallint not null default 1,
  ekleyen            integer not null default 0,
  ekleme_tarihi      timestamptz not null default now(),
  degistiren         integer not null default 0,
  degistirme_tarihi  timestamptz
);
comment on table public.dis_lab is 'Anlaşmalı protez laboratuvarı (706): tedarikçi cari + SLA.';

create table if not exists public.dis_lab_isemri (
  id                 integer generated by default as identity primary key,
  sube_id            integer not null default 0,
  isemri_no          varchar(20) not null default '',      -- LB-yyyy/nnnn
  lab_id             integer not null references public.dis_lab(id),
  hasta_id           integer not null references public.taraf(id),
  hekim_id           integer references public.taraf(id),
  plan_satir_id      integer references public.dis_tedavi_plani_satir(id),
  is_turu            smallint not null default 1,          -- dis.lab_is_turu
  dis_nolar          varchar(120) not null default '',
  malzeme            varchar(80) not null default '',
  renk               varchar(20) not null default '',      -- Vita
  olcu_tipi          smallint not null default 1,          -- dis.olcu_tipi
  ek_istek           varchar(400) not null default '',
  gonderim_tarihi    date,
  beklenen_tarih     date,
  teslim_tarihi      date,
  asama              smallint not null default 1,          -- dis.lab_asama
  kalite_kontrol     smallint not null default 0,
  lab_fiyat          numeric(18,2) not null default 0,
  hasta_fiyat        numeric(18,2) not null default 0,
  alis_belge_satir_id integer references public.belge_satir(id),
  garanti_bitis      date,
  aciklama           varchar(300) not null default '',
  ekleyen            integer not null default 0,
  ekleme_tarihi      timestamptz not null default now(),
  degistiren         integer not null default 0,
  degistirme_tarihi  timestamptz
);
create index if not exists ix_dis_lab_isemri_hasta on public.dis_lab_isemri (hasta_id);
create index if not exists ix_dis_lab_isemri_asama on public.dis_lab_isemri (sube_id, asama, beklenen_tarih);
create unique index if not exists ux_dis_lab_isemri_no on public.dis_lab_isemri (isemri_no) where isemri_no <> '';
comment on table public.dis_lab_isemri is 'Lab iş emri (706): ölçü → gönderim → tasarım → üretim → geldi → prova → teslim.';

create table if not exists public.dis_lab_isemri_asama (
  id                 integer generated by default as identity primary key,
  isemri_id          integer not null references public.dis_lab_isemri(id) on delete cascade,
  asama              smallint not null default 1,
  zaman              timestamptz not null default now(),
  kullanici_id       integer not null default 0,
  not_metin          varchar(300) not null default '',
  randevu_id         integer references public.randevu(id),
  sube_id            integer not null default 0,
  ekleyen            integer not null default 0,
  ekleme_tarihi      timestamptz not null default now(),
  degistiren         integer not null default 0,
  degistirme_tarihi  timestamptz
);
create index if not exists ix_dis_lab_asama_isemri on public.dis_lab_isemri_asama (isemri_id, zaman);

-- ============================================================== ödeme planı ==
create table if not exists public.dis_odeme_plani (
  id                 integer generated by default as identity primary key,
  sube_id            integer not null default 0,
  plan_id            integer not null references public.dis_tedavi_plani(id) on delete cascade,
  toplam             numeric(18,2) not null default 0,
  pesinat            numeric(18,2) not null default 0,
  taksit_sayisi      smallint not null default 1,
  taksit_tutar       numeric(18,2) not null default 0,
  ilk_vade           date,
  odeme_yontemi      smallint not null default 1,          -- dis.odeme_yontemi
  durum              smallint not null default 1,          -- 1 açık · 2 tamamlandı · 3 iptal
  aciklama           varchar(300) not null default '',
  ekleyen            integer not null default 0,
  ekleme_tarihi      timestamptz not null default now(),
  degistiren         integer not null default 0,
  degistirme_tarihi  timestamptz
);
create unique index if not exists ux_dis_odeme_plani_plan on public.dis_odeme_plani (plan_id);

create table if not exists public.dis_odeme_taksit (
  id                 integer generated by default as identity primary key,
  odeme_plani_id     integer not null references public.dis_odeme_plani(id) on delete cascade,
  sira               smallint not null default 1,
  vade               date not null,
  tutar              numeric(18,2) not null default 0,
  odenen             numeric(18,2) not null default 0,
  odeme_tarihi       date,
  mali_hareket_id    integer,
  durum              smallint not null default 1,          -- 1 bekliyor · 2 ödendi · 3 gecikti
  sube_id            integer not null default 0,
  ekleyen            integer not null default 0,
  ekleme_tarihi      timestamptz not null default now(),
  degistiren         integer not null default 0,
  degistirme_tarihi  timestamptz
);
create index if not exists ix_dis_odeme_taksit_plan on public.dis_odeme_taksit (odeme_plani_id, sira);

-- ============================================== geç bağlanan yabancı anahtarlar ==
do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'fk_dis_odontogram_seans') then
    alter table public.dis_odontogram
      add constraint fk_dis_odontogram_seans foreign key (seans_id) references public.dis_seans(id);
  end if;
  if not exists (select 1 from pg_constraint where conname = 'fk_dis_odontogram_plan_satir') then
    alter table public.dis_odontogram
      add constraint fk_dis_odontogram_plan_satir foreign key (plan_satir_id)
      references public.dis_tedavi_plani_satir(id);
  end if;
  if not exists (select 1 from pg_constraint where conname = 'fk_dis_plan_satir_lab') then
    alter table public.dis_tedavi_plani_satir
      add constraint fk_dis_plan_satir_lab foreign key (lab_isemri_id) references public.dis_lab_isemri(id);
  end if;
end $$;

-- ================================================ mevcut tablolara ek kolonlar ==
-- hizmet: diş işlemi bayrakları. Katalogdaki SUT diş kalemleri (40xxxx) ve
--   adında "diş" geçen kalemler işaretlenir; kurum daha sonra kartından
--   düzeltir - blanket değil, yalnız işaretsiz satırlar.
alter table public.hizmet add column if not exists dis_islem          smallint not null default 0;
alter table public.hizmet add column if not exists dis_bazli          smallint not null default 0;
alter table public.hizmet add column if not exists yuzey_bazli        smallint not null default 0;
alter table public.hizmet add column if not exists standart_seans     smallint not null default 1;
alter table public.hizmet add column if not exists standart_sure_dk   smallint not null default 30;
alter table public.hizmet add column if not exists lab_gerekir        smallint not null default 0;
alter table public.hizmet add column if not exists dis_onam_tur       smallint not null default 0;
alter table public.hizmet add column if not exists ucret_kurali       smallint not null default 1;
alter table public.hizmet add column if not exists odontogram_sonuc_kod smallint;
alter table public.hizmet add column if not exists dis_islem_grubu    smallint not null default 0;
comment on column public.hizmet.dis_islem is 'Diş işlemi mi (706) - plan satırı yalnız bu bayraklı hizmetten doğar.';
comment on column public.hizmet.odontogram_sonuc_kod is 'İşlem tamamlanınca dişe yazılacak durum (dis.durum): kron → 30, kanal → 20.';
create index if not exists ix_hizmet_dis on public.hizmet (dis_islem_grubu) where dis_islem = 1;

update public.hizmet
   set dis_islem = 1, dis_bazli = 1
 where dis_islem = 0
   and (kod ~ '^40[1-9][0-9]{3}$' or ad ilike '%diş%');

-- randevu: ünit + plan satırı + lab bağı (mockup notu: ayrı diş takvimi yok).
alter table public.randevu add column if not exists unit_id       integer references public.dis_unit(id);
alter table public.randevu add column if not exists plan_satir_id integer references public.dis_tedavi_plani_satir(id);
alter table public.randevu add column if not exists lab_isemri_id integer references public.dis_lab_isemri(id);
create index if not exists ix_randevu_unit on public.randevu (unit_id, baslangic) where unit_id is not null;

-- belge_satir: ücret satırı hangi plan satırından / seanstan / dişten doğdu.
alter table public.belge_satir add column if not exists plan_satir_id integer references public.dis_tedavi_plani_satir(id);
alter table public.belge_satir add column if not exists seans_id      integer references public.dis_seans(id);
alter table public.belge_satir add column if not exists dis_no        smallint;

-- tanı / radyoloji istem: diş numarası (e-Nabız 103 Diş Muayene paketi ister).
alter table public.tani add column if not exists dis_no smallint;
alter table public.radyoloji_istem add column if not exists dis_no   smallint;
alter table public.radyoloji_istem add column if not exists seans_id integer references public.dis_seans(id);

-- ============================================================== numaralar ==
-- Plan ve iş emri numarası yıl bazlı sayaç: TP-2026/0412 · LB-2026/0388.
create or replace function public.fn_dis_no_uret(p_onek varchar) returns varchar
language plpgsql as $$
declare
  v_yil  text := to_char(now(), 'YYYY');
  v_son  integer;
begin
  if p_onek = 'TP' then
    select coalesce(max(substring(plan_no from 9)::integer), 0) into v_son
      from public.dis_tedavi_plani
     where plan_no like 'TP-' || v_yil || '/%';
  else
    select coalesce(max(substring(isemri_no from 9)::integer), 0) into v_son
      from public.dis_lab_isemri
     where isemri_no like 'LB-' || v_yil || '/%';
  end if;
  return p_onek || '-' || v_yil || '/' || lpad((v_son + 1)::text, 4, '0');
end $$;

-- Plan toplamları satırlardan türetilir - iki yerde ayrı hesap ayrışırdı.
create or replace function public.fn_dis_plan_toplam_tazele(p_plan_id integer) returns void
language sql as $$
  update public.dis_tedavi_plani p
     set toplam  = k.toplam, indirim = k.indirim, net = k.net,
         degistirme_tarihi = now()
    from (select coalesce(sum(liste_fiyat), 0) as toplam,
                 coalesce(sum(iskonto), 0)     as indirim,
                 coalesce(sum(net), 0)         as net
            from public.dis_tedavi_plani_satir
           where plan_id = p_plan_id and durum <> 4) k
   where p.id = p_plan_id;
$$;

-- =================================================================== yetki ==
-- Ekran yetkileri KAYNAK (tur 0) - 692 dersi: tur 1 ekran açmaz.
insert into public.yetki (kod, ad, grup, tur, sira, aktif)
select 'dis', 'Diş Kliniği', 'Diş', 0, 37, 1
 where not exists (select 1 from public.yetki where kod = 'dis');

insert into public.yetki (kod, ad, grup, tur, sira, aktif)
select v.kod, v.ad, 'Diş', v.tur, v.sira, 1 from (values
    ('dis.hasta',              'Diş hasta kartı (odontogram)',        0, 1),
    ('dis.muayene',            'Diş muayenesi',                       0, 2),
    ('dis.plan',               'Tedavi planı & proforma',             0, 3),
    ('dis.plan.onayla',        'Tedavi planını onayla',               1, 4),
    ('dis.plan.fiyat_degistir','Plan satırı fiyatını değiştir',       1, 5),
    ('dis.seans',              'Seans kaydı',                         0, 6),
    ('dis.seans.bitir',        'Seansı bitir (ücretlendir)',          1, 7),
    ('dis.lab',                'Lab iş emirleri',                     0, 8),
    ('dis.odeme',              'Ödeme planı & borçlu hastalar',       0, 9),
    ('dis.unit',               'Ünitler & laboratuvarlar (ayar)',     0, 10)
  ) as v(kod, ad, tur, sira)
 where not exists (select 1 from public.yetki y where y.kod = v.kod);

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici'
   and (y.kod = 'dis' or y.kod like 'dis.%')
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

-- ================================================================ lookup'lar ==
create or replace view public.v_dis_unit_lookup as
select u.id, (u.kod || ' · ' || u.ad)::varchar(120) as ad, u.sube_id, u.aktif
  from public.dis_unit u where u.aktif = 1;

create or replace view public.v_dis_lab_lookup as
select l.id, l.ad::varchar(120) as ad, l.sube_id, l.aktif
  from public.dis_lab l where l.aktif = 1;

-- Diş işlemi seçimi: yalnız dis_islem = 1 hizmetler (on binlik katalog değil).
create or replace view public.v_dis_islem_lookup as
select h.id,
       (coalesce(nullif(h.kod, '') || ' · ', '') || h.ad)::varchar(200) as ad,
       h.sube_id,
       case when coalesce(h.durum, 1) = 1 then 1 else 0 end as aktif
  from public.hizmet h
 where h.dis_islem = 1 and h.baslik_mi = 0 and coalesce(h.durum, 1) = 1;

create or replace view public.v_dis_plan_lookup as
select p.id, (p.plan_no || ' · ' || t.unvan)::varchar(160) as ad, p.sube_id,
       case when p.durum in (1,2,3,4) then 1 else 0 end as aktif
  from public.dis_tedavi_plani p join public.taraf t on t.id = p.hasta_id;

-- ========================================================= liste görünümleri ==
-- Tedavi planları: hasta, hekim, satır sayısı, yapılan/toplam, bakiye.
create or replace view public.v_dis_tedavi_plani as
select p.id, p.sube_id, p.plan_no, p.hasta_id, t.unvan as hasta_adi,
       p.hekim_id, h.unvan as hekim_adi, p.varyant, p.durum,
       p.toplam, p.indirim, p.net, p.gecerlilik_bitis, p.hasta_onay_zamani,
       p.proforma_no, p.ekleme_tarihi::date as tarih,
       (select count(*) from public.dis_tedavi_plani_satir s where s.plan_id = p.id and s.durum <> 4)::int as satir_sayisi,
       (select count(*) from public.dis_tedavi_plani_satir s where s.plan_id = p.id and s.durum = 3)::int as yapilan_sayisi,
       (select coalesce(sum(s.net), 0) from public.dis_tedavi_plani_satir s where s.plan_id = p.id and s.durum = 3) as yapilan_tutar,
       (select coalesce(sum(k.odenen), 0) from public.dis_odeme_plani o
          join public.dis_odeme_taksit k on k.odeme_plani_id = o.id where o.plan_id = p.id) as tahsil
  from public.dis_tedavi_plani p
  join public.taraf t on t.id = p.hasta_id
  left join public.taraf h on h.id = p.hekim_id;

create or replace view public.v_dis_lab_isemri as
select i.id, i.sube_id, i.isemri_no, i.lab_id, l.ad as lab_adi, i.hasta_id, t.unvan as hasta_adi,
       i.hekim_id, h.unvan as hekim_adi, i.plan_satir_id, i.is_turu, i.dis_nolar, i.malzeme, i.renk,
       i.gonderim_tarihi, i.beklenen_tarih, i.teslim_tarihi, i.asama, i.lab_fiyat, i.hasta_fiyat,
       case when i.asama in (8, 9) then 0
            when i.beklenen_tarih is not null and i.beklenen_tarih < current_date then 1 else 0 end as gecikti,
       (select r.baslangic from public.randevu r where r.lab_isemri_id = i.id and r.durum <> 4
         order by r.baslangic desc limit 1) as sonraki_randevu
  from public.dis_lab_isemri i
  join public.dis_lab l on l.id = i.lab_id
  join public.taraf t on t.id = i.hasta_id
  left join public.taraf h on h.id = i.hekim_id;

create or replace view public.v_dis_seans as
select s.id, s.sube_id, s.hasta_id, t.unvan as hasta_adi, s.hekim_id, h.unvan as hekim_adi,
       s.unit_id, u.ad as unit_adi, s.plan_id, p.plan_no, s.randevu_id, s.belge_id,
       s.baslangic, s.bitis, s.sure_dk, s.durum,
       (select count(*) from public.dis_seans_islem i where i.seans_id = s.id)::int as islem_sayisi,
       (select string_agg(hz.ad, ' · ' order by i.id) from public.dis_seans_islem i
          join public.hizmet hz on hz.id = i.hizmet_id where i.seans_id = s.id) as islemler
  from public.dis_seans s
  join public.taraf t on t.id = s.hasta_id
  left join public.taraf h on h.id = s.hekim_id
  left join public.dis_unit u on u.id = s.unit_id
  left join public.dis_tedavi_plani p on p.id = s.plan_id;

-- GÜNLÜK AKIŞ: satır = diş randevusu (bölüm 2 = Diş ya da ünitli randevu),
--   plan satırı, açık seans, plan durumu ve bakiye tek satırda. Çizelge ve
--   liste AYNI görünümden beslenir.
create or replace view public.v_dis_gunluk_akis as
select r.id, r.sube_id, r.baslangic, r.sure_dk, r.durum as randevu_durum,
       r.hasta_id, t.unvan as hasta_adi,
       extract(year from age(current_date, th.dogum_tarihi))::int as yas,
       r.hekim_id, h.unvan as hekim_adi, r.unit_id, u.ad as unit_adi, u.kod as unit_kod,
       r.plan_satir_id, ps.plan_id, p.plan_no, ps.sira as plan_sira,
       coalesce(hz.ad, r.aciklama) as planli_islem,
       ps.dis_no, ps.seans_sayisi, ps.yapilan_seans, ps.lab_isemri_id,
       li.asama as lab_asama,
       p.durum as plan_durum,
       case when p.id is null then 0 else
         (select count(*) from public.dis_tedavi_plani_satir x where x.plan_id = p.id and x.durum = 3) end::int as plan_yapilan,
       case when p.id is null then 0 else
         (select count(*) from public.dis_tedavi_plani_satir x where x.plan_id = p.id and x.durum <> 4) end::int as plan_toplam_satir,
       coalesce((select sum(x.net) from public.dis_tedavi_plani_satir x where x.plan_id = p.id and x.durum = 3), 0)
         - coalesce((select sum(k.odenen) from public.dis_odeme_plani o
                       join public.dis_odeme_taksit k on k.odeme_plani_id = o.id where o.plan_id = p.id), 0) as bakiye,
       s.id as seans_id, s.baslangic as seans_baslangic, s.durum as seans_durum,
       r.belge_id
  from public.randevu r
  join public.taraf t on t.id = r.hasta_id
  left join public.taraf_hasta th on th.id = r.hasta_id
  left join public.taraf h on h.id = r.hekim_id
  left join public.dis_unit u on u.id = r.unit_id
  left join public.dis_tedavi_plani_satir ps on ps.id = r.plan_satir_id
  left join public.dis_tedavi_plani p on p.id = ps.plan_id
  left join public.hizmet hz on hz.id = coalesce(ps.hizmet_id, r.hizmet_id)
  left join public.dis_lab_isemri li on li.id = ps.lab_isemri_id
  left join lateral (select x.id, x.baslangic, x.durum from public.dis_seans x
                      where x.randevu_id = r.id order by x.id desc limit 1) s on true
 where r.bolum = 2 or r.unit_id is not null;

comment on view public.v_dis_gunluk_akis is
  'Diş günlük akışı (706): diş randevuları + plan satırı + açık seans + bakiye. Çizelge ve liste aynı görünümü okur.';

-- Hasta listesi (diş hasta kartına giriş): hasta rollü kartlar + aktif plan.
create or replace view public.v_dis_hasta as
select t.id, t.sube_id, t.unvan, t.telefon, t.cep_tel,
       th.dogum_tarihi, extract(year from age(current_date, th.dogum_tarihi))::int as yas,
       (select count(*) from public.dis_odontogram o where o.hasta_id = t.id and o.aktif = 1 and o.katman = 1 and o.durum_kod <> 0)::int as bulgu_sayisi,
       (select p.plan_no from public.dis_tedavi_plani p where p.hasta_id = t.id and p.durum in (3,4)
         order by p.id desc limit 1) as aktif_plan_no,
       (select max(s.baslangic) from public.dis_seans s where s.hasta_id = t.id) as son_seans,
       (select max(m.muayene_tarihi) from public.muayene m where m.taraf_id = t.id) as son_muayene
  from public.taraf t
  join public.taraf_hasta th on th.id = t.id
 where t.hasta = 1;
