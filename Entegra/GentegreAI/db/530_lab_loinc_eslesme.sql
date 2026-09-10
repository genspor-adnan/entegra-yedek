-- =====================================================================
--  530_lab_loinc_eslesme.sql
--  LAB TETKİĞİ ↔ LOINC eşlemesi.
--
--  Kullanıcı: "loinc kodlarını da eşleştir."
--
--  SKRS RESMİ EŞLEME VERMİYOR - önce arandı: 499 kod sisteminde SUT kodunu
--  LOINC'e bağlayan liste yok. "SUTVS İLİŞKİSİ" (3.314 satır) SUT kodunu
--  MSVS veri setine bağlar, LOINC'e değil; LOINC listesinin kendisinde de
--  SUT kodu alanı yok. Bu yüzden eşleme METİN BENZERLİĞİYLE kurulur ve
--  TAHMİN OLDUĞU KAYIT ALTINDA TUTULUR - yanlış bir LOINC kodu e-Nabız'a ve
--  uluslararası kayda yanlış test adıyla gider.
--
--  İKİ KADEMELİ: yüksek güvenli eşleşme kendiliğinden yazılır, geri kalan
--  ADAY olarak durur. Bir insan onaylamadan kartın koduna yazılmaz.
--    * analit adı BİREBİR aynıysa            -> otomatik
--    * benzerlik ≥ eşik (varsayılan 0,70)    -> otomatik
--    * 0,45 - 0,70 arası                     -> aday listesi (en iyi 5)
--
--  KARŞILAŞTIRMA ANALİT ADI ÜZERİNDEN: SUT adı "KREATİNİN (SERUM/PLAZMA)",
--  LOINC adı "Kreatinin [Kütle/hacim] Serum veya Plazmada" - parantez ve
--  köşeli parantezden sonrası ölçüm birimi/numune bilgisidir, benzerliği
--  bastırır. İkisinin de baş kısmı alınır; numune uyumu ise AYRI bir
--  sıralama ölçütüdür (aynı analitin serum ve idrar LOINC'i farklıdır -
--  "Albümin BOS'ta" kodunu serum tetkikine yazmak sessiz bir hatadır).
--
--  TÜRKÇE LOINC HAVUZU KÜÇÜKTÜR: 91.395 LOINC kaydının yalnız 3.172'sinde
--  Türkçe karşılık var. Eşleşmeyen tetkik BOŞ KALIR - uydurma kod yazmaktan
--  iyidir; ileride resmi eşleme gelirse aynı fonksiyon yeniden koşar.
-- =====================================================================

create index if not exists ix_skrs_loinc_analit on public.skrs_loinc
  using gin (lower(split_part(turkce_ad, '[', 1)) gin_trgm_ops) where turkce_ad <> '';

create table if not exists public.lab_tetkik_loinc_aday (
    tetkik_id     integer  not null references public.lab_tetkik(id) on delete cascade,
    numara        varchar(20) not null,       -- skrs_loinc.numara
    skor          numeric(5,3) not null,
    numune_uyar   smallint not null default 0,
    sira          smallint not null default 0,
    uretim        timestamp not null default now(),
    primary key (tetkik_id, numara)
);
comment on table public.lab_tetkik_loinc_aday is
    'LOINC eşleme ADAYLARI (530): metin benzerliğiyle bulunur, insan onaylayınca lab_tetkik.loinc olur.';

/** Tetkiğin numune tipi ile LOINC adındaki numune metni uyuyor mu (530). */
create or replace function public.fn_lab_loinc_numune_uyar(
    p_numune smallint, p_loinc_ad text)
returns smallint language sql immutable as $$
    select case
        when p_numune in (1, 2)
             and (p_loinc_ad ilike '%serum%' or p_loinc_ad ilike '%plazma%') then 1
        when p_numune = 3 and p_loinc_ad ilike '%kan%'    then 1
        when p_numune = 4 and p_loinc_ad ilike '%idrar%'  then 1
        when p_numune = 5 and (p_loinc_ad ilike '%gaita%' or p_loinc_ad ilike '%dışkı%') then 1
        when p_numune = 6 and p_loinc_ad ilike '%bos%'    then 1
        else 0 end::smallint;
$$;

/**
 * Tetkik adı ile LOINC Türkçe adı arasında eşleme kurar.
 *
 * p_esik    : bu benzerliğin üstü KENDİLİĞİNDEN yazılır (analit adı birebir
 *             aynıysa benzerlikten bağımsız yazılır)
 * p_aday_alt: aday listesine girmenin alt sınırı
 * Dönen     : otomatik yazılan tetkik sayısı.
 */
create or replace function public.fn_lab_loinc_esle(
    p_esik numeric default 0.70, p_aday_alt numeric default 0.45)
returns integer language plpgsql as $$
declare v_yazilan integer;
begin
    -- 1) ADAYLAR: her tetkik için en iyi 5. Tablo her koşuda yenilenir -
    --    tetkik adı ya da LOINC havuzu değişince eski aday yanıltmasın.
    delete from public.lab_tetkik_loinc_aday;

    insert into public.lab_tetkik_loinc_aday (tetkik_id, numara, skor, numune_uyar, sira)
    select t.id, a.numara, round(a.skor::numeric, 3), a.numune_uyar, a.sira
      from (select id, ad, numune_tipi, btrim(split_part(ad, '(', 1)) as analit
              from public.lab_tetkik) t
      cross join lateral (
        select l.numara,
               similarity(lower(t.analit), lower(split_part(l.turkce_ad, '[', 1))) as skor,
               public.fn_lab_loinc_numune_uyar(t.numune_tipi, l.turkce_ad) as numune_uyar,
               row_number() over (
                 order by (lower(btrim(split_part(l.turkce_ad, '[', 1))) = lower(t.analit)) desc,
                          public.fn_lab_loinc_numune_uyar(t.numune_tipi, l.turkce_ad) desc,
                          similarity(lower(t.analit), lower(split_part(l.turkce_ad, '[', 1))) desc,
                          length(l.turkce_ad)) as sira
          from public.skrs_loinc l
         where l.turkce_ad <> ''
           and lower(split_part(l.turkce_ad, '[', 1)) % lower(t.analit)
         limit 5) a
     where a.skor >= p_aday_alt;

    -- 2) OTOMATİK YAZIM: yalnız en iyi aday, yalnız eşiğin üstü, yalnız
    --    LOINC'i BOŞ tetkiğe. Kullanıcının yazdığı kod ezilmez.
    --
    --    İKİ EK KOŞUL - denetimde çıkan iki sessiz hata yüzünden:
    --      * NUMUNE UYUMU ARANIR: "KLORÜR (BOS)" tetkiğine benzerlik 1,000 ile
    --        "Klorür [Mol/hacim] TERDE" kodu yazılıyordu. Numunesi belirsiz
    --        olanlarda (Swab / Diğer) uyum aranamaz - onlar adayda kalır.
    --      * RAKAM UYUMU ARANIR: "KOAGÜLASYON FAKTÖR 9 İNHİBİTÖR" tetkiğine
    --        "faktör II inhibitörü" kodu yazılıyordu (benzerlik 0,931).
    --        Tetkik adındaki sayı LOINC adında geçmiyorsa otomatik yazılmaz.
    update public.lab_tetkik t
       set loinc = a.numara
      from public.lab_tetkik_loinc_aday a
      join public.skrs_loinc l on l.numara = a.numara
     where a.tetkik_id = t.id and a.sira = 1
       and a.skor >= p_esik
       and coalesce(t.loinc, '') = ''
       and (a.numune_uyar = 1 or t.numune_tipi in (7, 9))
       and (substring(t.ad from '[0-9]+') is null
            or l.turkce_ad like '%' || substring(t.ad from '[0-9]+') || '%');
    get diagnostics v_yazilan = row_count;

    -- Hizmet kartındaki LOINC de izler: satılan kalemle çalışılan test aynı
    --   uluslararası kodu taşır (519'daki ayrım: lab_tetkik.loinc çalışılan,
    --   hizmet.loinc satılan kalem).
    update public.hizmet h
       set loinc = left(t.loinc, 12)
      from public.lab_tetkik t
     where t.hizmet_id = h.id and coalesce(t.loinc, '') <> ''
       and coalesce(h.loinc, '') = '';

    return v_yazilan;
end $$;

comment on function public.fn_lab_loinc_esle(numeric, numeric) is
    'Tetkik ↔ LOINC eşlemesi (530): metin benzerliği; eşik üstü otomatik, gerisi aday - SKRS resmi eşleme vermiyor.';

/** Onaylanmayı bekleyen eşlemeler - ekranda "LOINC önerisi" listesi. */
create or replace view public.v_lab_loinc_oneri as
select t.id            as tetkik_id,
       t.kod           as tetkik_kod,
       t.ad            as tetkik_ad,
       t.loinc         as yazili_loinc,
       a.numara        as onerilen_loinc,
       l.turkce_ad     as loinc_ad,
       l.ornek_birim,
       a.skor,
       a.numune_uyar
  from public.lab_tetkik t
  join public.lab_tetkik_loinc_aday a on a.tetkik_id = t.id and a.sira = 1
  join public.skrs_loinc l on l.numara = a.numara
 where coalesce(t.loinc, '') = '';

comment on view public.v_lab_loinc_oneri is
    'LOINC''i boş tetkikler için en iyi öneri ve benzerlik skoru (530) - insan onayı bekler.';

do $$
declare
    v_yazilan integer;
    v_aday    integer;
    v_bos     integer;
begin
    select public.fn_lab_loinc_esle() into v_yazilan;
    select count(*) into v_aday from public.lab_tetkik_loinc_aday;
    select count(*) into v_bos from public.lab_tetkik where coalesce(loinc, '') = '';
    raise notice '530: % tetkiğe LOINC yazıldı · % aday satırı · % tetkik hâlâ boş.',
                 v_yazilan, v_aday, v_bos;
end $$;
