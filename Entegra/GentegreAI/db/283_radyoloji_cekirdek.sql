-- 283: RADYOLOJİ MODÜLÜ — ÇEKİRDEK ŞEMA (Faz 1).
--
-- Kapsam: tetkik tanımı (hizmet kartının uzantısı), cihaz, çekim protokolü,
-- İSTEM (worklist'in kaynağı), RAPOR ve rapor ŞABLONU.
--
-- TEMEL KARAR — istem neden ayrı tablo:
--   belge_satir TİCARİ kayıttır (ne satıldı, kaça, kim ödeyecek); istem KLİNİK
--   kayıttır (ne zaman çekildi, hangi cihaz, hangi doz, hangi study). İkisinin
--   yaşam döngüsü ayrıdır: başvuru iptal edilse de çekilmiş görüntü ortada
--   durur, istem iptal edilse de ücret satırı kalabilir. Bağ tek yönlü ve
--   1:1'dir: her radyoloji hizmeti satırı EN FAZLA bir istem doğurur.
--
-- Fiyat/ödeyen kurum İSTEMDE TEKRAR EDİLMEZ - belgede durur (274 zinciri:
-- kurum sözleşmesi > cari kampanyası > genel; baz liste kampanyadan).

-- =========================================================== tetkik tanımı ==
-- Radyoloji tetkiki AYRI BİR VARLIK DEĞİL, satılan bir hizmettir: fiyatı fiyat
-- listesinden, indirimi kampanyadan gelir, başvuru satırında satılır. Hizmet
-- kartına yalnız radyolojiye özgü üç alan eklenir.
alter table public.hizmet add column if not exists radyoloji smallint not null default 0;
alter table public.hizmet add column if not exists modalite  smallint;
-- SUT kodu SGK/sigorta mutabakatının anahtarıdır; icmal eşleşmesi buna bakar.
--   ozel_kod'a sıkıştırılırsa iki farklı amaç tek alanda çakışır.
alter table public.hizmet add column if not exists sut_kodu  varchar(20) not null default '';

comment on column public.hizmet.radyoloji is
  'Radyoloji tetkiki mi (283) - istem YALNIZ bu bayraklı hizmet satırından doğar.';
comment on column public.hizmet.modalite is
  'Modalite (283, kod_liste rad.modalite): 1 BT · 2 MR · 3 USG · 4 Röntgen · 5 Mamografi · 6 DEXA · 7 Anjiyo · 8 Skopi.';
comment on column public.hizmet.sut_kodu is
  'SUT / kurum mutabakat kodu (283). SGK ve sigorta icmalinde eşleşme bu kodla yapılır.';

create index if not exists ix_hizmet_radyoloji on public.hizmet (modalite)
  where radyoloji = 1;

-- ============================================================ kod listeleri ==
insert into public.kod_liste (kod, ad)
select v.kod, v.ad from (values
    ('rad.modalite',    'Radyoloji Modalitesi'),
    ('rad.istem_durum', 'Radyoloji İstem Durumu'),
    ('rad.oncelik',     'Radyoloji Öncelik'),
    ('rad.rapor_durum', 'Radyoloji Rapor Durumu'),
    ('rad.kontrast',    'Kontrast Kullanımı'),
    ('rad.teslim_turu', 'Sonuç Teslim Türü')
  ) as v(kod, ad)
 where not exists (select 1 from public.kod_liste k where k.kod = v.kod);

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  join (values
    ('rad.modalite', 1, 'BT'), ('rad.modalite', 2, 'MR'), ('rad.modalite', 3, 'USG'),
    ('rad.modalite', 4, 'Röntgen'), ('rad.modalite', 5, 'Mamografi'),
    ('rad.modalite', 6, 'DEXA'), ('rad.modalite', 7, 'Anjiyo'), ('rad.modalite', 8, 'Skopi'),
    -- İstem durumu worklist akışıdır; sıra ANLAMLIDIR (geriye dönüş yok).
    ('rad.istem_durum', 0, 'İptal'),    ('rad.istem_durum', 1, 'Bekliyor'),
    ('rad.istem_durum', 2, 'Çekildi'),  ('rad.istem_durum', 3, 'Raporlanıyor'),
    ('rad.istem_durum', 4, 'Ön Rapor'), ('rad.istem_durum', 5, 'Onaylandı'),
    ('rad.istem_durum', 6, 'Teslim Edildi'),
    ('rad.oncelik', 1, 'Normal'), ('rad.oncelik', 2, 'Acil'),
    ('rad.rapor_durum', 1, 'Taslak'), ('rad.rapor_durum', 2, 'Ön Rapor'),
    ('rad.rapor_durum', 3, 'Onaylı'),
    ('rad.kontrast', 0, 'Verilmedi'), ('rad.kontrast', 1, 'İV'),
    ('rad.kontrast', 2, 'Oral'), ('rad.kontrast', 3, 'İV + Oral'), ('rad.kontrast', 4, 'Rektal'),
    ('rad.teslim_turu', 1, 'Hasta Portalı'), ('rad.teslim_turu', 2, 'Basılı Rapor'),
    ('rad.teslim_turu', 3, 'CD / DVD'), ('rad.teslim_turu', 4, 'Film'),
    ('rad.teslim_turu', 5, 'e-Posta')
  ) as v(liste, deger, ad) on v.liste = l.kod
 where not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger);

-- ================================================================ HEKİM rolu ==
-- Dış istem hekimi SERBEST METİN OLAMAZ: SGK/sigorta faturasında ve raporda
-- isteyen hekimin kimliği (diploma/tescil) aranır. Kurum deseniyle aynı:
-- taraf'ta rol bayrağı + 1:1 detay tablosu.
alter table public.taraf add column if not exists hekim smallint not null default 0;
comment on column public.taraf.hekim is 'Hekim rolü (283) - iç ya da dış istem hekimi.';
create index if not exists ix_taraf_hekim_rol on public.taraf (hekim) where hekim = 1;

create table if not exists public.taraf_hekim (
  id            integer not null primary key references public.taraf(id) on delete cascade,
  brans         varchar(80)  not null default '',
  diploma_no    varchar(30)  not null default '',
  tescil_no     varchar(30)  not null default '',
  -- Dış hekim: kurum dışından istem yapan. Kurum adı kart olarak da tutulabilir
  --   (istek_kurum_id), tek seferlik gelenler için serbest alan yeter.
  dis_mi        smallint     not null default 0,
  kurum_adi     varchar(150) not null default '',
  aciklama      varchar(300) not null default '',
  ekleyen       integer not null default 0,
  ekleme_tarihi timestamp not null default now()::timestamp,
  degistiren    integer not null default 0,
  degistirme_tarihi timestamp
);
comment on table public.taraf_hekim is 'Hekim kimliği (283): branş, diploma/tescil, iç/dış.';

-- AYRI AD: `v_hekim_lookup` randevuda kullaniliyor (personel + randevu
-- verilebilir). Istem hekimi ondan GENIS bir kume - ic hekimlerin yani sira
-- DIS hekimleri de icerir; o gorunumu ezmek randevu hekim secimini bozardi.
create or replace view public.v_rad_hekim_lookup as
select t.id,
       trim(coalesce(t.unvan, '')
            || case when coalesce(h.brans, '') <> '' then ' · ' || h.brans else '' end
            || case when coalesce(h.dis_mi, 0) = 1 then ' (dış)' else '' end)::varchar(200) as ad,
       case when coalesce(t.durum, 1) = 1 then 1 else 0 end as aktif
  from public.taraf t
  left join public.taraf_hekim h on h.id = t.id
 where t.hekim = 1
    or (t.personel = 1 and t.randevu_verilebilir = 1);

-- =================================================================== cihaz ==
-- AE Title DICOM kimliğidir: worklist (MWL) doğru cihaza ancak bununla iner.
create table if not exists public.radyoloji_cihaz (
  id            integer generated by default as identity primary key,
  kod           varchar(20)  not null default '',
  ad            varchar(120) not null,
  modalite      smallint     not null,
  ae_title      varchar(32)  not null default '',
  oda           varchar(60)  not null default '',
  sube_id       integer      not null default 0,
  durum         smallint     not null default 1,
  aciklama      varchar(300) not null default '',
  ekleyen       integer not null default 0,
  ekleme_tarihi timestamp not null default now()::timestamp,
  degistiren    integer not null default 0,
  degistirme_tarihi timestamp
);
comment on table public.radyoloji_cihaz is 'Modalite cihazları (283). AE Title = DICOM MWL hedefi.';
create unique index if not exists ux_radyoloji_cihaz_kod on public.radyoloji_cihaz (lower(kod))
  where kod <> '';

-- =========================================================== çekim protokolü ==
-- Tetkikin NASIL çekileceği: süre randevu kapasitesini, hazırlık metni hastaya
-- gönderilen talimatı besler.
create table if not exists public.radyoloji_protokol (
  hizmet_id       integer not null primary key references public.hizmet(id) on delete cascade,
  modalite        smallint,
  sure_dk         smallint not null default 15,
  kontrast        smallint not null default 0,          -- rad.kontrast varsayılanı
  seri_tarifi     varchar(400) not null default '',     -- sekans / pozisyon
  hazirlik_metni  varchar(600) not null default '',     -- "4 saat aç gelin" vb.
  ozel_uyari      varchar(400) not null default '',     -- gebelik, metal, kreatinin
  ekleyen         integer not null default 0,
  ekleme_tarihi   timestamp not null default now()::timestamp,
  degistiren      integer not null default 0,
  degistirme_tarihi timestamp
);
comment on table public.radyoloji_protokol is
  'Tetkikin çekim protokolü (283): süre, kontrast, hazırlık talimatı.';

-- ==================================================================== İSTEM ==
create table if not exists public.radyoloji_istem (
  id              integer generated by default as identity primary key,
  sube_id         integer not null default 0,
  -- Ücret bağı: belge_satir 1:1. belge_id DENORMALİZE - worklist sorgusu her
  --   satır için belge_satir'a inmesin.
  belge_id        integer references public.belge(id),
  belge_satir_id  integer references public.belge_satir(id),
  hasta_id        integer not null references public.taraf(id),
  hizmet_id       integer not null references public.hizmet(id),
  modalite        smallint not null default 0,
  accession_no    varchar(24) not null,
  durum           smallint not null default 1,          -- rad.istem_durum
  oncelik         smallint not null default 1,          -- 1 normal / 2 acil
  -- İsteyen: iç hekim (taraf) ya da dış hekim/kurum.
  istek_hekim_id  integer references public.taraf(id),
  istek_kurum_id  integer references public.taraf(id),
  dis_hekim_ad    varchar(120) not null default '',
  on_tani         varchar(20)  not null default '',     -- ICD-10
  klinik_bilgi    varchar(600) not null default '',
  randevu_id      integer references public.randevu(id),
  -- Çekim
  cihaz_id        integer references public.radyoloji_cihaz(id),
  tekniker_id     integer references public.taraf(id),
  cekim_tarihi    timestamp,
  kontrast        smallint not null default 0,
  kontrast_ml     numeric(9,2),
  -- Doz: BT ve skopide zorunlu takip (hasta dozimetrisi).
  dlp             numeric(12,2),
  ctdi            numeric(12,2),
  -- PACS eşleşmesi
  study_uid       varchar(64) not null default '',
  seri_sayisi     smallint not null default 0,
  goruntu_sayisi  integer  not null default 0,
  aciklama        varchar(300) not null default '',
  ekleyen         integer not null default 0,
  ekleme_tarihi   timestamp not null default now()::timestamp,
  degistiren      integer not null default 0,
  degistirme_tarihi timestamp
);
comment on table public.radyoloji_istem is
  'Radyoloji istemi (283) - worklist''in kaynağı. belge_satir ile 1:1, accession no PACS anahtarı.';

create unique index if not exists ux_radyoloji_istem_accession
  on public.radyoloji_istem (accession_no);
-- Bir hizmet satırı EN FAZLA bir istem doğurur: iki accession aynı satıra
--   bağlanırsa hangi çekimin faturalandığı belirsizleşir.
create unique index if not exists ux_radyoloji_istem_satir
  on public.radyoloji_istem (belge_satir_id) where belge_satir_id is not null;
create index if not exists ix_radyoloji_istem_worklist
  on public.radyoloji_istem (durum, oncelik desc, cekim_tarihi);
create index if not exists ix_radyoloji_istem_hasta on public.radyoloji_istem (hasta_id);
create index if not exists ix_radyoloji_istem_belge on public.radyoloji_istem (belge_id)
  where belge_id is not null;
create index if not exists ix_radyoloji_istem_study on public.radyoloji_istem (study_uid)
  where study_uid <> '';

-- ------------------------------------------------------ accession üretimi ---
-- ACC-YYMMDD-nnnn: gün içinde sıra. Eşzamanlı kabulde çakışmasın diye advisory
-- lock alınır (unique index ikinci savunma hattıdır).
create or replace function public.fn_radyoloji_accession(p_tarih date default current_date)
returns varchar
language plpgsql as $$
declare
  v_on   text := 'ACC-' || to_char(p_tarih, 'YYMMDD') || '-';
  v_sira integer;
begin
  perform pg_advisory_xact_lock(hashtext('radyoloji_accession'));
  select coalesce(max(substring(accession_no from '\d+$')::integer), 0) + 1
    into v_sira
    from public.radyoloji_istem
   where accession_no like v_on || '%';
  return v_on || lpad(v_sira::text, 4, '0');
end $$;

comment on function public.fn_radyoloji_accession(date) is
  'Sıradaki accession no (283): ACC-YYMMDD-nnnn.';

-- =================================================================== ŞABLON ==
create table if not exists public.radyoloji_sablon (
  id            integer generated by default as identity primary key,
  kod           varchar(20)  not null default '',
  ad            varchar(150) not null,
  modalite      smallint,
  -- Şablon TETKİKE bağlanır: rapor kartı açılınca varsayılanı kendiliğinden yüklenir.
  hizmet_id     integer references public.hizmet(id),
  bolum         varchar(60)  not null default '',       -- Nöroradyoloji, Meme…
  varsayilan    smallint not null default 0,
  surum         integer  not null default 1,
  durum         smallint not null default 1,
  kullanim      integer  not null default 0,
  aciklama      varchar(300) not null default '',
  sube_id       integer not null default 0,
  ekleyen       integer not null default 0,
  ekleme_tarihi timestamp not null default now()::timestamp,
  degistiren    integer not null default 0,
  degistirme_tarihi timestamp
);
comment on table public.radyoloji_sablon is 'Rapor şablonu (283) - tetkike bağlı, sürümlü.';
create unique index if not exists ux_radyoloji_sablon_kod
  on public.radyoloji_sablon (lower(kod)) where kod <> '';
-- Bir tetkikte tek varsayılan şablon: ikisi birden varsayılansa hangisinin
--   açılacağı rastgele olurdu.
create unique index if not exists ux_radyoloji_sablon_varsayilan
  on public.radyoloji_sablon (hizmet_id) where varsayilan = 1 and hizmet_id is not null;

create table if not exists public.radyoloji_sablon_bolum (
  id             integer generated by default as identity primary key,
  sablon_id      integer not null references public.radyoloji_sablon(id) on delete cascade,
  sira           smallint not null default 1,
  baslik         varchar(60) not null,
  varsayilan_metin text not null default '',
  zorunlu        smallint not null default 0,
  -- Yazdır kapalı bölüm ekranda görünür ama hasta çıktısına basılmaz (iç not).
  yazdir         smallint not null default 1
);
create index if not exists ix_radyoloji_sablon_bolum on public.radyoloji_sablon_bolum (sablon_id, sira);

create table if not exists public.radyoloji_sablon_makro (
  id           integer generated by default as identity primary key,
  sablon_id    integer not null references public.radyoloji_sablon(id) on delete cascade,
  kisayol      varchar(20) not null,                    -- .nrm
  ad           varchar(80) not null default '',
  metin        text not null default '',
  hedef_bolum  varchar(60) not null default ''
);
create index if not exists ix_radyoloji_sablon_makro on public.radyoloji_sablon_makro (sablon_id);

-- ==================================================================== RAPOR ==
create table if not exists public.radyoloji_rapor (
  id             integer generated by default as identity primary key,
  istem_id       integer not null references public.radyoloji_istem(id) on delete cascade,
  sablon_id      integer references public.radyoloji_sablon(id),
  -- Şablonun O ANKİ sürümü saklanır: şablon sonradan değişince geçmiş rapor
  --   değişmemeli.
  sablon_surum   integer not null default 1,
  durum          smallint not null default 1,           -- 1 taslak · 2 ön rapor · 3 onaylı
  yazan_id       integer references public.taraf(id),
  yazma_tarihi   timestamp,
  onaylayan_id   integer references public.taraf(id),
  onay_tarihi    timestamp,
  -- Onaylanan rapor KİLİTLİDİR; düzeltme ancak ek rapor (addendum) olarak
  --   yazılır ve ayrıca imzalanır. ust_rapor_id doluysa bu bir addendum'dur.
  kilit          smallint not null default 0,
  ust_rapor_id   integer references public.radyoloji_rapor(id),
  ekleyen        integer not null default 0,
  ekleme_tarihi  timestamp not null default now()::timestamp,
  degistiren     integer not null default 0,
  degistirme_tarihi timestamp
);
comment on table public.radyoloji_rapor is
  'Radyoloji raporu (283). Onaylı rapor kilitlenir; düzeltme addendum (ust_rapor_id) olarak eklenir.';
create index if not exists ix_radyoloji_rapor_istem on public.radyoloji_rapor (istem_id);
-- Bir istemde tek ANA rapor (addendum'lar ust_rapor_id ile bağlanır).
create unique index if not exists ux_radyoloji_rapor_ana
  on public.radyoloji_rapor (istem_id) where ust_rapor_id is null;

create table if not exists public.radyoloji_rapor_bolum (
  id        integer generated by default as identity primary key,
  rapor_id  integer not null references public.radyoloji_rapor(id) on delete cascade,
  sira      smallint not null default 1,
  baslik    varchar(60) not null,
  metin     text not null default '',
  yazdir    smallint not null default 1
);
create index if not exists ix_radyoloji_rapor_bolum on public.radyoloji_rapor_bolum (rapor_id, sira);

-- Yapılandırılmış alanlar (BI-RADS, TI-RADS, Pfirrmann…): rapora BASILIR ve
-- ayrıca SAYISAL saklanır - takip ve istatistik ancak böyle yapılabilir.
create table if not exists public.radyoloji_rapor_alan (
  id        integer generated by default as identity primary key,
  rapor_id  integer not null references public.radyoloji_rapor(id) on delete cascade,
  alan_kod  varchar(40) not null,
  alan_ad   varchar(80) not null default '',
  deger     varchar(120) not null default ''
);
create index if not exists ix_radyoloji_rapor_alan on public.radyoloji_rapor_alan (rapor_id);
create index if not exists ix_radyoloji_rapor_alan_kod on public.radyoloji_rapor_alan (alan_kod, deger);

-- ======================================================== belge silme engeli ==
-- Çekilmiş isteminin belgesi silinemez: görüntü ve rapor ortadayken ücret
-- kaydının yok olması izi koparır (ÜTS engelinin aynısı).
do $$
declare
  v_kaynak text;
begin
  select pg_get_functiondef(oid) into v_kaynak
    from pg_proc where proname = 'fn_belge_silinebilir';

  if v_kaynak like '%radyoloji_istem%' then
    raise notice '283: fn_belge_silinebilir zaten radyoloji engelini iceriyor.';
  else
    v_kaynak := replace(v_kaynak,
      '    return '''';                                   -- bos = silinebilir',
      '    -- RADYOLOJI (283): cekilmis istem klinik kayittir.' || chr(10) ||
      '    select count(*) into v_adet' || chr(10) ||
      '      from public.radyoloji_istem ri' || chr(10) ||
      '     where ri.belge_id = p_belge_id and ri.durum >= 2;' || chr(10) ||
      '    if v_adet > 0 then' || chr(10) ||
      '        return ''Belgenin çekilmiş radyoloji istemi var; önce istemi iptal edin.'';' || chr(10) ||
      '    end if;' || chr(10) || chr(10) ||
      '    return '''';                                   -- bos = silinebilir');
    execute v_kaynak;
    raise notice '283: fn_belge_silinebilir radyoloji engeliyle guncellendi.';
  end if;
end $$;

-- ==================================================================== yetki ==
insert into public.yetki (kod, ad, grup, tur, sira, aktif)
select 'radyoloji', 'Radyoloji', 'belge', 0, 34, 1
 where not exists (select 1 from public.yetki where kod = 'radyoloji');

insert into public.yetki (kod, ad, grup, tur, sira, aktif)
select v.kod, v.ad, 'radyoloji', 1, v.sira, 1 from (values
    ('rad.istem_iptal',   'Radyoloji istemini iptal et', 1),
    ('rad.rapor_yaz',     'Radyoloji raporu yaz',        2),
    ('rad.rapor_onayla',  'Radyoloji raporunu onayla',   3),
    ('rad.teslim',        'Radyoloji sonucu teslim et',  4)
  ) as v(kod, ad, sira)
 where not exists (select 1 from public.yetki y where y.kod = v.kod);

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici'
   and y.kod in ('radyoloji', 'rad.istem_iptal', 'rad.rapor_yaz', 'rad.rapor_onayla', 'rad.teslim')
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

-- ================================================================= worklist ==
create or replace view public.v_radyoloji_worklist as
select i.id, i.sube_id, i.accession_no, i.durum, i.oncelik, i.modalite,
       coalesce(md.ad, '')                       as modalite_adi,
       coalesce(dd.ad, '')                       as durum_adi,
       i.cekim_tarihi, i.hasta_id,
       coalesce(h.unvan, '')                     as hasta_adi,
       coalesce(hz.kod, '')                      as tetkik_kodu,
       coalesce(hz.ad, '')                       as tetkik_adi,
       coalesce(ih.unvan, nullif(i.dis_hekim_ad, '')) as isteyen,
       coalesce(ik.unvan, '')                    as isteyen_kurum,
       i.belge_id, b.belge_no,
       coalesce(ok.unvan, '')                    as odeyen_kurum,
       r.id                                      as rapor_id,
       coalesce(r.durum, 0)                      as rapor_durum,
       coalesce(ry.unvan, '')                    as raporlayan,
       -- Bekleme: çekimden bu yana (çekilmediyse istem açılışından).
       round(extract(epoch from (now()::timestamp
             - coalesce(i.cekim_tarihi, i.ekleme_tarihi))) / 60)::integer as bekleme_dk
  from public.radyoloji_istem i
  left join public.taraf  h  on h.id  = i.hasta_id
  left join public.hizmet hz on hz.id = i.hizmet_id
  left join public.taraf  ih on ih.id = i.istek_hekim_id
  left join public.taraf  ik on ik.id = i.istek_kurum_id
  left join public.belge  b  on b.id  = i.belge_id
  left join public.taraf  ok on ok.id = b.odeyen_kurum_id
  left join public.radyoloji_rapor r on r.istem_id = i.id and r.ust_rapor_id is null
  left join public.taraf  ry on ry.id = coalesce(r.onaylayan_id, r.yazan_id)
  left join public.kod_deger md on md.deger = i.modalite
       and md.liste_id = (select id from public.kod_liste where kod = 'rad.modalite')
  left join public.kod_deger dd on dd.deger = i.durum
       and dd.liste_id = (select id from public.kod_liste where kod = 'rad.istem_durum');

comment on view public.v_radyoloji_worklist is
  'Radyoloji çalışma listesi (283): istem + hasta + tetkik + rapor durumu tek satırda.';
