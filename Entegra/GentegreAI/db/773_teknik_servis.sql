-- ============================================================================
--  Gentegre AI — TEKNİK SERVİS: ÇAĞRI · İŞ EMRİ · ZİYARET
--  773_teknik_servis.sql
--
--  Kullanıcı: "hem erp hem de hbys de kullanılmak üzere teknik servis modülü"
--  + "saha ekranını da ekle" → mockup `Ekranlar/TeknikServis/*.html`, ardından
--  "şema ve uçları yaz".
--
--  ============ TEK İŞ EMRİ, İKİ SAHİPLİK ==============================
--  ERP'de teknik servis MÜŞTERİNİN cihazını onarır ve para kazanır; HBYS'de
--  KURUMUN cihazını onarır ve maliyet üretir. Yapılan iş aynıdır: arıza gelir,
--  teşhis konur, parça takılır, işçilik harcanır, cihaz test edilip teslim
--  edilir.
--
--  Bu yüzden ikinci bir iş emri tablosu AÇILMIYOR. `demirbas_is_emri` (541)
--  zaten iç işi karşılıyor; eksik olan sahibinin MÜŞTERİ olabilmesiydi.
--  Tabloya `sahiplik` geldi ve `demirbas_id` zorunlu olmaktan çıktı:
--
--      sahiplik 1 (iç)  → demirbas_id zorunlu, ücret yok, maliyet birime
--      sahiplik 2 (dış) → musteri_taraf_id zorunlu, ücretli, faturaya döner
--
--  Tablonun adı tarihsel kaldı (`demirbas_is_emri`): veri ve bağları duran bir
--  tabloyu yalnız adı için yeniden adlandırmak, kazancından çok risk taşırdı.
--  Okunur ad görünümlerde: `v_servis_is_emri`.
--
--  ============ ÜÇ KATMAN: ÇAĞRI → İŞ EMRİ → ZİYARET ===================
--  Saha servisinde bunlar AYNI ŞEY DEĞİLDİR ve tek düzeyde tutmak ölçmeyi
--  imkânsız kılar:
--
--    `servis_cagri`   müşterinin aramasıdır; SLA saati ONUNLA başlar.
--    iş emri          o çağrıyı kapatmak için yapılan iştir.
--    `servis_ziyaret` bir gidiştir; bir çağrının birden çok ziyareti olur.
--
--  Taahhüt ilk yanıta, memnuniyet kapanışa bakar. "İlk gidişte çözüm oranı"
--  saha servisinin asıl verimlilik ölçüsüdür ve ancak ziyaretler ayrı kayıtsa
--  hesaplanabilir - ikinci ziyaret, ücretsiz bir yoldur.
--
--  ============ KAPSAM: TUTAR HEP HESAPLANIR ===========================
--  `kapsam_tur` tutarın KİME yazıldığını belirler; dördü de ayrı davranır:
--    1 Ücretli           → müşteriye faturalanır
--    2 Sözleşme          → tahsil edilmez, sözleşme kârlılığına yazılır
--    3 Üretici garantisi → ÜRETİCİYE faturalanır (yetkili serviste GELİRDİR)
--    4 Kendi garantimiz  → bizim sattığımız cihaz; maliyet garanti giderine
--
--  Hiçbirinde tutar sıfırlanmaz, yalnız tahsil yolu değişir: sıfır yazmak
--  "bu işin maliyeti neydi" sorusunu sonsuza dek cevapsız bırakır ve sözleşme
--  fiyatı yenilemesi tahmine kalırdı.
-- ============================================================================
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------- 1
--  MÜŞTERİ CİHAZ PARKI
--
--  Müşterinin cihazı bizim demirbaşımız DEĞİLDİR ama servisini veriyorsak
--  kaydı bizde olmalı: "hangi müşteride hangi cihaz var, garantisi ne zaman
--  bitiyor, hangisi sözleşme dışında" sorusu hem satışın hem servisin sorusu.
--
--  Yalnız seri numarasıyla geçmiş tutmak HİÇ ARIZALANMAMIŞ cihazı görünmez
--  yapardı - oysa yenileme ve sözleşme teklifi tam onlara gider.
--
--  BİZİM SATMADIĞIMIZ CİHAZ DA GİRER: `satis_belge_id` boş kalır.
create table if not exists public.taraf_cihaz (
    id                integer generated always as identity primary key,
    taraf_id          integer      not null references public.taraf(id),
    sube_id           integer      not null default 0,
    ad                varchar(150) not null,
    marka             varchar(80)  not null default '',
    model             varchar(80)  not null default '',
    seri_no           varchar(60)  not null default '',
    stok_id           integer      references public.stok(id),
    kurulum_tarihi    date,
    garanti_bitis     date,
    -- Bizden alınmışsa satış belgesi; garanti tartışmasının dayanağı.
    satis_belge_id    integer,
    adres             varchar(300) not null default '',
    bolge             varchar(60)  not null default '',
    durum             smallint     not null default 1,
    aciklama          varchar(300) not null default '',
    ekleyen           integer      not null default 0,
    ekleme_tarihi     timestamptz  not null default now(),
    degistiren        integer      not null default 0,
    degistirme_tarihi timestamptz
);

-- SERİ NO MÜŞTERİDE TEKTİR: aynı müşteride aynı seri iki kez girilirse cihaz
--   geçmişi ikiye bölünür. Seri numarası BOŞ olabilir (eski cihaz, sökülmüş
--   etiket) - kısmi index onu serbest bırakır.
create unique index if not exists ux_taraf_cihaz_seri
    on public.taraf_cihaz (taraf_id, upper(seri_no))
 where coalesce(seri_no, '') <> '';
create index if not exists ix_taraf_cihaz_taraf
    on public.taraf_cihaz (taraf_id, durum);

comment on table public.taraf_cihaz is
  '773: musteri cihaz parki - servisini verdigimiz, bize AIT OLMAYAN cihazlar. '
  'Bizim satmadigimiz cihaz da girer (satis_belge_id bos).';

-- ---------------------------------------------------------------------- 2
--  BAKIM SÖZLEŞMESİ
--
--  SLA SÖZLEŞMEDEN GELİR, çağrının önceliğinden değil: aynı arıza 4 saatlik
--  sözleşmede acil, 24 saatlikte normaldir. Öncelik teknisyenin sırasını,
--  SLA taahhüdü belirler - ikisini karıştırmak, cezalı gecikmeyi "normal
--  öncelikli iş" diye bekletmek olurdu.
create table if not exists public.servis_sozlesme (
    id                integer generated always as identity primary key,
    taraf_id          integer      not null references public.taraf(id),
    sube_id           integer      not null default 0,
    sozlesme_no       varchar(30)  not null default '',
    baslangic         date         not null,
    bitis             date         not null,
    -- 1 işçilik · 2 işçilik + yol · 3 tam kapsam (parça dahil)
    kapsam            smallint     not null default 1,
    sla_saat          smallint     not null default 24,
    -- Periyodik bakım sıklığı (ay); 0 = periyodik bakım yok.
    periyot_ay        smallint     not null default 0,
    yillik_bedel      numeric(18,2) not null default 0,
    durum             smallint     not null default 1,
    aciklama          varchar(300) not null default '',
    ekleyen           integer      not null default 0,
    ekleme_tarihi     timestamptz  not null default now(),
    degistiren        integer      not null default 0,
    degistirme_tarihi timestamptz,
    constraint ck_servis_sozlesme_tarih check (bitis >= baslangic)
);
create index if not exists ix_servis_sozlesme_taraf
    on public.servis_sozlesme (taraf_id, durum, bitis);

alter table public.taraf_cihaz
    add column if not exists sozlesme_id integer references public.servis_sozlesme(id);

comment on table public.servis_sozlesme is
  '773: bakim sozlesmesi. SLA buradan gelir - cagrinin onceliginden DEGIL.';

-- ---------------------------------------------------------------------- 3
--  SERVİS ÇAĞRISI
--
--  Çağrı müşterinin aramasıdır ve SLA saati onunla başlar. ATANMAMIŞ ÇAĞRIDA
--  DA İŞLER: kimsenin işi olmaması taahhüdü durdurmaz - bu yüzden `sla_bitis`
--  açılışta yazılır, teknisyen atandığında değil.
create table if not exists public.servis_cagri (
    id                bigint generated always as identity primary key,
    cagri_no          varchar(30)  not null default '',
    sube_id           integer      not null default 0,
    taraf_id          integer      not null references public.taraf(id),
    taraf_cihaz_id    integer      references public.taraf_cihaz(id),
    sozlesme_id       integer      references public.servis_sozlesme(id),
    -- Cihaz parkta yoksa beyan edilen bilgi (ilk çağrıda çoğu zaman böyledir).
    cihaz_metni       varchar(200) not null default '',
    sikayet           varchar(600) not null,
    -- 1 ücretli · 2 sözleşme · 3 üretici garantisi · 4 kendi garantimiz
    kapsam_tur        smallint     not null default 1,
    oncelik           smallint     not null default 3,
    bildiren          varchar(120) not null default '',
    telefon           varchar(30)  not null default '',
    acilis            timestamptz  not null default now(),
    sla_bitis         timestamptz,
    ilk_yanit         timestamptz,
    kapanis           timestamptz,
    -- 0 açık · 1 atandı · 2 yolda · 3 yerinde · 4 parça bekliyor
    -- 5 çözüldü · 8 iptal
    durum             smallint     not null default 0,
    sonuc             varchar(400) not null default '',
    aciklama          varchar(300) not null default '',
    ekleyen           integer      not null default 0,
    ekleme_tarihi     timestamptz  not null default now(),
    degistiren        integer      not null default 0,
    degistirme_tarihi timestamptz,
    constraint ck_servis_cagri_kapsam check (kapsam_tur between 1 and 4)
);
create unique index if not exists ux_servis_cagri_no
    on public.servis_cagri (sube_id, cagri_no) where cagri_no <> '';
create index if not exists ix_servis_cagri_acik
    on public.servis_cagri (sube_id, durum, sla_bitis) where durum < 5;

comment on table public.servis_cagri is
  '773: servis cagrisi - SLA saati BUNUNLA baslar. Bir cagriyi kapatmak icin '
  'acilan is (demirbas_is_emri) ve her gidis (servis_ziyaret) ayri katmandir.';

-- ---------------------------------------------------------------------- 4
--  İŞ EMRİ: SAHİPLİK VE ÜCRET ALANLARI
--
--  Var olan tabloya eklenir - ikinci bir iş emri tablosu açmak, parça çıkışını,
--  işçilik kaydını ve cihaz geçmişini ikiye bölerdi.
alter table public.demirbas_is_emri
    -- 1 iç (kurum demirbaşı) · 2 dış (müşteri cihazı)
    add column if not exists sahiplik         smallint not null default 1,
    add column if not exists cagri_id         bigint   references public.servis_cagri(id),
    add column if not exists musteri_taraf_id integer  references public.taraf(id),
    add column if not exists taraf_cihaz_id   integer  references public.taraf_cihaz(id),
    add column if not exists sozlesme_id      integer  references public.servis_sozlesme(id),
    add column if not exists kapsam_tur       smallint not null default 1,
    add column if not exists iscilik_tutar    numeric(18,2) not null default 0,
    add column if not exists parca_tutar      numeric(18,2) not null default 0,
    add column if not exists diger_tutar      numeric(18,2) not null default 0,
    add column if not exists toplam_tutar     numeric(18,2) not null default 0,
    add column if not exists teklif_no        varchar(30) not null default '',
    add column if not exists belge_id         integer;

-- DEMİRBAŞ ARTIK ZORUNLU DEĞİL: müşteri cihazı envanterimizde yok.
alter table public.demirbas_is_emri alter column demirbas_id drop not null;

-- SAHİPLİK NE DERSE O DOLU OLMALI. Kısıt olmadan "iç iş ama cihazı yok" ya da
--   "dış iş ama müşterisi yok" satırları sessizce doğar ve ikisi de raporda
--   sahipsiz kalırdı.
alter table public.demirbas_is_emri
    drop constraint if exists ck_demirbas_is_emri_sahiplik;
alter table public.demirbas_is_emri
    add constraint ck_demirbas_is_emri_sahiplik check (
        (sahiplik = 1 and demirbas_id is not null)
     or (sahiplik = 2 and musteri_taraf_id is not null));

comment on column public.demirbas_is_emri.sahiplik is
  '773: 1 ic (kurum demirbasi, ucret yok) · 2 dis (musteri cihazi, ucretli).';
comment on column public.demirbas_is_emri.kapsam_tur is
  '773: 1 ucretli · 2 sozlesme · 3 uretici garantisi (URETICIYE faturalanir) '
  '· 4 kendi garantimiz. Tutar hicbirinde sifirlanmaz, tahsil yolu degisir.';

-- ---------------------------------------------------------------------- 5
--  ZİYARET (BİR GİDİŞ)
create table if not exists public.servis_ziyaret (
    id                bigint generated always as identity primary key,
    is_emri_id        bigint   not null references public.demirbas_is_emri(id)
                                 on delete cascade,
    sira              smallint not null default 1,
    teknisyen_id      integer,
    plan_zamani       timestamptz,
    varis             timestamptz,
    ayrilis           timestamptz,
    -- Yol da bir maliyettir: Çerkezköy'e 96 km giden teknisyenin günü dört
    --   saat kısalır. Çizelgede boş görünen saat aslında yoldadır.
    yol_km            numeric(10,1) not null default 0,
    arac              varchar(40)  not null default '',
    mesai_disi        smallint     not null default 0,
    yapilan           varchar(600) not null default '',
    -- 0 sürüyor · 1 çözüldü · 2 çözülemedi · 3 parça bekliyor · 4 iptal
    sonuc             smallint     not null default 0,
    sonuc_metni       varchar(400) not null default '',
    -- İMZASIZ ZİYARET KAPANMAZ: yerinde yapılan işin tek kanıtı müşterinin
    --   onayıdır. Alınamıyorsa gerekçe yazılır ve çağrı AÇIK kalır.
    imza_alindi       smallint     not null default 0,
    imza_notu         varchar(200) not null default '',
    iscilik_saat      numeric(8,2) not null default 0,
    tutar             numeric(18,2) not null default 0,
    ekleyen           integer      not null default 0,
    ekleme_tarihi     timestamptz  not null default now(),
    degistiren        integer      not null default 0,
    degistirme_tarihi timestamptz
);
create index if not exists ix_servis_ziyaret_is_emri
    on public.servis_ziyaret (is_emri_id, sira);
create index if not exists ix_servis_ziyaret_teknisyen
    on public.servis_ziyaret (teknisyen_id, plan_zamani);

comment on table public.servis_ziyaret is
  '773: bir gidis. Ilk gidiste cozum orani ancak ziyaretler AYRI kayitsa '
  'olculebilir - ikinci ziyaret ucretsiz bir yoldur.';

-- Parça hangi ziyarette takıldı: araç stoğu sayımı ve "ikinci gidişte ne
--   götürüldü" sorusu bunsuz cevaplanamaz.
alter table public.demirbas_is_emri_parca
    add column if not exists ziyaret_id bigint references public.servis_ziyaret(id),
    -- Sökülen arızalı parçanın üreticiye iadesi: üretici garantisinde iade
    --   edilmezse alacak REDDEDİLİR.
    add column if not exists iade_durum smallint not null default 0;

-- ---------------------------------------------------------------------- 6
--  EMANET / YEDEK CİHAZ
--
--  Emanet cihaz SATIŞ DEĞİLDİR: stoktan düşmez, ayrı hareketle izlenir.
--  İade edilmeden iş emri kapanmaz - kapanan iş emriyle birlikte unutulan
--  emanet, envanterde "depoda" yazan ama sahada duran cihaz demektir.
create table if not exists public.servis_emanet (
    id                bigint generated always as identity primary key,
    emanet_no         varchar(30)  not null default '',
    sube_id           integer      not null default 0,
    is_emri_id        bigint       references public.demirbas_is_emri(id),
    taraf_id          integer      references public.taraf(id),
    -- Kurum içinde yerine konan cihaz demirbaştır; müşteriye verilen
    --   emanet havuzundan çıkar ve demirbaş olmayabilir.
    demirbas_id       integer      references public.demirbas(id),
    cihaz_metni       varchar(200) not null default '',
    veris             timestamptz  not null default now(),
    iade              timestamptz,
    durum             smallint     not null default 1,
    aciklama          varchar(300) not null default '',
    ekleyen           integer      not null default 0,
    ekleme_tarihi     timestamptz  not null default now(),
    degistiren        integer      not null default 0,
    degistirme_tarihi timestamptz
);
create unique index if not exists ux_servis_emanet_no
    on public.servis_emanet (sube_id, emanet_no) where emanet_no <> '';
create index if not exists ix_servis_emanet_acik
    on public.servis_emanet (durum, veris) where durum = 1;

comment on table public.servis_emanet is
  '773: emanet/yedek cihaz. Stoktan DUSMEZ. Iade edilmeden is emri kapanmaz.';

-- ---------------------------------------------------------------------- 7
--  TOPLAM TEK YERDE HESAPLANIR
--
--  İşçilik ziyaretlerden, parça parça satırlarından gelir. Uçta toplamak,
--  ekranda görünen tutarla faturaya giden tutarın ayrışmasına açık kapı
--  bırakırdı (masraf beyanında aynı karar verilmişti: tg_masraf_toplam).
create or replace function public.fn_servis_is_emri_topla(p_is_emri bigint)
returns void language sql as $$
    update public.demirbas_is_emri e
       set iscilik_tutar = coalesce((select sum(z.tutar) from public.servis_ziyaret z
                                      where z.is_emri_id = e.id), 0),
           parca_tutar   = coalesce((select sum(p.miktar * p.birim_fiyat)
                                       from public.demirbas_is_emri_parca p
                                      where p.is_emri_id = e.id), 0),
           toplam_tutar  = coalesce((select sum(z.tutar) from public.servis_ziyaret z
                                      where z.is_emri_id = e.id), 0)
                         + coalesce((select sum(p.miktar * p.birim_fiyat)
                                       from public.demirbas_is_emri_parca p
                                      where p.is_emri_id = e.id), 0)
                         + e.diger_tutar,
           degistirme_tarihi = now()
     where e.id = p_is_emri;
$$;

create or replace function public.tg_servis_toplam()
returns trigger language plpgsql as $$
begin
    perform public.fn_servis_is_emri_topla(
        coalesce(new.is_emri_id, old.is_emri_id));
    return null;
end $$;

drop trigger if exists trg_servis_ziyaret_toplam on public.servis_ziyaret;
create trigger trg_servis_ziyaret_toplam
 after insert or update or delete on public.servis_ziyaret
    for each row execute function public.tg_servis_toplam();

drop trigger if exists trg_servis_parca_toplam on public.demirbas_is_emri_parca;
create trigger trg_servis_parca_toplam
 after insert or update or delete on public.demirbas_is_emri_parca
    for each row execute function public.tg_servis_toplam();

-- ---------------------------------------------------------------------- 8
--  SLA BİTİŞİ
--
--  Sözleşme varsa onun saati, yoksa kurum varsayılanı (`servis.sla_saat`).
--  Ayar da yoksa SLA YOKTUR: uydurulmuş bir taahhüt, tutulmadığında kimsenin
--  sözünü vermediği bir borç yaratır.
create or replace function public.fn_servis_sla_bitis(
        p_sozlesme integer, p_acilis timestamptz)
returns timestamptz language sql stable as $$
    select case
        when p_sozlesme is not null then
            p_acilis + make_interval(hours => (select sla_saat
                                                 from public.servis_sozlesme
                                                where id = p_sozlesme))
        when coalesce((select deger from public.referans
                        where anahtar = 'servis.sla_saat'), '') ~ '^[0-9]+$' then
            p_acilis + make_interval(hours => (select deger::int
                                                 from public.referans
                                                where anahtar = 'servis.sla_saat'))
        else null
    end;
$$;

insert into public.referans (anahtar, deger, aciklama)
select 'servis.sla_saat', '',
       'Sozlesmesiz cagrilarda varsayilan SLA (saat). Bos = taahhut yok (773).'
 where not exists (select 1 from public.referans where anahtar = 'servis.sla_saat');

-- ---------------------------------------------------------------------- 9
--  NUMARALAR (900+ kodlar, 767 deseni)
--  909 ve 918 SEÇİLDİ, 910 DEĞİL: 731 (tedarik) 910-917 arasını çoktan
--  almış (910 Eczane Hazırlama, 914 İş Emri...). Bu dosyanın ilk yazımında
--  910 "Emanet Cihaz No" olarak konmuştu ve Belge No ekranında aynı kod iki
--  farklı ad gösterecekti - tam da 755/756/757'de temizlenen çakışma sınıfı.
--  Bir tür kodu eklemeden ÖNCE var olan v_numara_turu_* görünümlerine bakın.
create or replace view public.v_numara_turu_servis as
select 909 as id, 'Servis Çağrı No'::varchar as ad, 1::smallint as aktif
union all select 918, 'Emanet Cihaz No'::varchar, 1::smallint;

insert into public.numara_sablonu (tur, baslama_tarihi, on_ek, baslama_no,
                                   sube_id, durum, elle_girilir, aciklama)
select x.tur, current_date, x.on_ek, '000001', 0, 1, 0, x.aciklama
  from (values
    (909::smallint, 'CG-'::varchar, 'Servis cagri numarasi (773)'::varchar),
    (918::smallint, 'EM-'::varchar, 'Emanet cihaz numarasi (773)'::varchar)
  ) as x(tur, on_ek, aciklama)
 where not exists (select 1 from public.numara_sablonu s where s.tur = x.tur);

-- İŞ EMRİ NUMARASI YENİDEN TANIMLANMIYOR: 731 onu 914 olarak tanımlamış
--   (tedarik grubunda "İş Emri No"). Servis iş emri de aynı numaradan
--   kesilir - iki ayrı sayaç, aynı tabloda iki numara dizisi demekti.

-- --------------------------------------------------------------------- 10
--  GÖRÜNÜMLER
create or replace view public.v_taraf_cihaz as
select c.id, c.taraf_id, t.unvan as taraf_adi, c.sube_id,
       c.ad, c.marka, c.model, c.seri_no,
       trim(both ' ' from c.marka || ' ' || c.model) as marka_model,
       c.kurulum_tarihi, c.garanti_bitis,
       case when c.garanti_bitis is null then 0
            when c.garanti_bitis >= current_date then 1 else 2 end as garanti_durum,
       c.sozlesme_id, s.bitis as sozlesme_bitis,
       c.satis_belge_id, c.bolge, c.adres, c.durum, c.aciklama,
       (select count(*) from public.servis_cagri g where g.taraf_cihaz_id = c.id)
                                                     as cagri_sayisi
  from public.taraf_cihaz c
  join public.taraf t on t.id = c.taraf_id
  left join public.servis_sozlesme s on s.id = c.sozlesme_id;

create or replace view public.v_servis_cagri as
select g.id, g.cagri_no, g.sube_id, g.taraf_id, t.unvan as taraf_adi,
       g.taraf_cihaz_id,
       coalesce(nullif(g.cihaz_metni, ''),
                trim(both ' ' from coalesce(c.ad, '') || ' ' ||
                     coalesce(c.marka, '') || ' ' || coalesce(c.model, ''))) as cihaz,
       c.seri_no, g.sozlesme_id, g.kapsam_tur,
       case g.kapsam_tur when 1 then 'Ücretli' when 2 then 'Sözleşme'
                         when 3 then 'Üretici garantisi'
                         else 'Kendi garantimiz' end        as kapsam_adi,
       g.oncelik, g.bildiren, g.telefon, g.acilis, g.sla_bitis, g.ilk_yanit,
       g.kapanis, g.durum, g.sikayet, g.sonuc,
       coalesce(c.bolge, '') as bolge,
       -- SLA KALAN DAKİKA: eksi değer aşımdır. Kapanmış çağrıda null - geçmiş
       --   bir taahhüdü "gecikiyor" diye göstermek listeyi kirletirdi.
       case when g.durum >= 5 or g.sla_bitis is null then null
            else floor(extract(epoch from (g.sla_bitis - now())) / 60)::int end
                                                            as sla_kalan_dk,
       (select count(*) from public.demirbas_is_emri e where e.cagri_id = g.id)
                                                            as is_emri_sayisi,
       (select count(*) from public.servis_ziyaret z
          join public.demirbas_is_emri e2 on e2.id = z.is_emri_id
         where e2.cagri_id = g.id)                          as ziyaret_sayisi
  from public.servis_cagri g
  join public.taraf t on t.id = g.taraf_id
  left join public.taraf_cihaz c on c.id = g.taraf_cihaz_id;

create or replace view public.v_servis_is_emri as
select e.id, e.is_emri_no, e.sube_id, e.sahiplik,
       case e.sahiplik when 2 then 'Dış iş' else 'İç iş' end as sahiplik_adi,
       e.cagri_id, g.cagri_no,
       e.demirbas_id, e.musteri_taraf_id,
       coalesce(mt.unvan, d.ad, '')                          as sahip_adi,
       e.taraf_cihaz_id,
       coalesce(nullif(tc.ad, ''), d.ad, '')                 as cihaz,
       e.tur, e.oncelik, e.durum, e.kapsam_tur,
       case e.kapsam_tur when 1 then 'Ücretli' when 2 then 'Sözleşme'
                         when 3 then 'Üretici garantisi'
                         else 'Kendi garantimiz' end         as kapsam_adi,
       e.bildirim_zamani, e.ilk_mudahale, e.tamamlanma, e.planlanan,
       e.ariza_metni, e.yapilan_is,
       e.iscilik_tutar, e.parca_tutar, e.diger_tutar, e.toplam_tutar,
       e.teklif_no, e.belge_id, e.onay_durum, e.onayli_tutar,
       (select count(*) from public.servis_ziyaret z where z.is_emri_id = e.id)
                                                             as ziyaret_sayisi,
       (select count(*) from public.servis_emanet m
         where m.is_emri_id = e.id and m.durum = 1)          as acik_emanet
  from public.demirbas_is_emri e
  left join public.servis_cagri g  on g.id  = e.cagri_id
  left join public.taraf mt        on mt.id = e.musteri_taraf_id
  left join public.taraf_cihaz tc  on tc.id = e.taraf_cihaz_id
  left join public.demirbas d      on d.id  = e.demirbas_id;

create or replace view public.v_servis_ziyaret as
select z.id, z.is_emri_id, e.is_emri_no, e.sube_id, e.cagri_id, g.cagri_no,
       coalesce(mt.unvan, '') as taraf_adi,
       z.sira, z.teknisyen_id, coalesce(tk.unvan, '') as teknisyen_adi,
       z.plan_zamani, z.varis, z.ayrilis, z.yol_km, z.arac, z.mesai_disi,
       z.yapilan, z.sonuc,
       case z.sonuc when 1 then 'Çözüldü' when 2 then 'Çözülemedi'
                    when 3 then 'Parça bekliyor' when 4 then 'İptal'
                    else 'Sürüyor' end                      as sonuc_adi,
       z.sonuc_metni, z.imza_alindi, z.iscilik_saat, z.tutar,
       case when z.varis is not null and z.ayrilis is not null
            then round(extract(epoch from (z.ayrilis - z.varis)) / 3600.0, 2)
            else null end                                   as yerinde_saat
  from public.servis_ziyaret z
  join public.demirbas_is_emri e on e.id = z.is_emri_id
  left join public.servis_cagri g on g.id = e.cagri_id
  left join public.taraf mt on mt.id = e.musteri_taraf_id
  left join public.taraf tk on tk.id = z.teknisyen_id;

create or replace view public.v_servis_emanet as
select m.id, m.emanet_no, m.sube_id, m.is_emri_id, e.is_emri_no,
       m.taraf_id, coalesce(t.unvan, '') as taraf_adi,
       m.demirbas_id, coalesce(nullif(m.cihaz_metni, ''), d.ad, '') as cihaz,
       m.veris, m.iade, m.durum, m.aciklama,
       case when m.durum = 1
            then (current_date - m.veris::date) else null end as gun
  from public.servis_emanet m
  left join public.demirbas_is_emri e on e.id = m.is_emri_id
  left join public.taraf t on t.id = m.taraf_id
  left join public.demirbas d on d.id = m.demirbas_id;

create or replace view public.v_servis_sozlesme as
select s.id, s.sozlesme_no, s.taraf_id, t.unvan as taraf_adi, s.sube_id,
       s.baslangic, s.bitis, s.kapsam,
       case s.kapsam when 1 then 'İşçilik' when 2 then 'İşçilik + yol'
                     else 'Tam kapsam' end                  as kapsam_adi,
       s.sla_saat, s.periyot_ay, s.yillik_bedel, s.durum, s.aciklama,
       (s.bitis - current_date)                             as kalan_gun,
       (select count(*) from public.taraf_cihaz c where c.sozlesme_id = s.id)
                                                            as cihaz_sayisi,
       -- SLA AŞIMI SÖZLEŞMEYE YAZILIR: yenileme görüşmesinin ve cezanın girdisi.
       (select count(*) from public.servis_cagri g
         where g.sozlesme_id = s.id and g.sla_bitis is not null
           and coalesce(g.kapanis, now()) > g.sla_bitis)     as sla_asim
  from public.servis_sozlesme s
  join public.taraf t on t.id = s.taraf_id;

-- --------------------------------------------------------------------- 11
--  YETKİLER
--
--  `demirbas.isemri` var olan yetkidir (iç iş); servis modülü kendi kodunu
--  alır çünkü ERP kurulumunda demirbaş yetkisi olmayan bir servis ekibi
--  olabilir - biyomedikal ile saha servisi aynı kişiler değildir.
insert into public.yetki (kod, ad, grup, tur, sira)
select x.kod, x.ad, 'Teknik Servis'::varchar, x.tur, x.sira
  from (values
    ('servis',          'Teknik servis'::varchar,       0::smallint, 10::smallint),
    ('servis.cihaz',    'Müşteri cihaz parkı',          0::smallint, 20::smallint),
    ('servis.sozlesme', 'Servis sözleşmesi',            0::smallint, 30::smallint),
    -- TESLİM AYRI AKSİYON YETKİSİ (tur 1): iş emrini düzenlemek ile
    --   "teslim edildi, kapandı" demek aynı sorumluluk değil.
    ('servis.teslim',   'Servis teslim ve kapatma',     1::smallint, 40::smallint)
  ) as x(kod, ad, tur, sira)
 where not exists (select 1 from public.yetki y where y.kod = x.kod);

-- Yönetici rolü yeni yetkileri görür; öteki roller kurulumda verilir.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select 1, y.id, 1, 1, 1, 1
  from public.yetki y
 where y.kod in ('servis', 'servis.cihaz', 'servis.sozlesme', 'servis.teslim')
   and not exists (select 1 from public.rol_yetki r
                    where r.rol_id = 1 and r.yetki_id = y.id);

-- --------------------------------------------------------------------- 12
do $$
declare v_tablo int;
begin
    select count(*) into v_tablo from information_schema.tables
     where table_schema = 'public'
       and table_name in ('taraf_cihaz', 'servis_sozlesme', 'servis_cagri',
                          'servis_ziyaret', 'servis_emanet');
    raise notice '773 tamam: % yeni tablo, is emri sahiplik ile genisletildi '
                 '(demirbas_id artik zorunlu degil).', v_tablo;
end $$;
