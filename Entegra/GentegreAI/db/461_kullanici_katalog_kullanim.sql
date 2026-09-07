-- =====================================================================
-- 461 - KATALOG "SIK / SON KULLANILAN" (metin anahtarlı kataloglar)
--
-- `kullanici_arama` kart açılış sıklığını tutar ama anahtarı `bigint`:
-- ICD-10 gibi kataloglarda anahtar KODUN KENDİSİDİR ("I21.0"), sayısal id
-- yoktur. Bu yüzden metin anahtarlı kataloglar için ayrı tablo.
--
-- NEDEN GEREKLİ: poliklinikte tanı dağılımı dardır - hekimin yazdığı ilk beş
-- kod işin çoğunu görür. Her tanıda 20 bin satırlık katalogda arama yapmak
-- yerine "son / sık kullandıklarım" listesinden seçmek hem hızlı, hem de
-- AYNI hastalığın hep AYNI kodla yazılmasını sağlar (iki farklı ICD ile
-- yazılan aynı hastalık raporu ve e-Nabız paketini ikiye böler).
--
-- KULLANICI BAZLI: bir hekimin sık tanısı diğerininkiyle aynı değildir;
-- kurum geneli sayaç kardiyolojinin listesini dahiliyeciye gösterirdi.
-- =====================================================================

create table if not exists public.kullanici_katalog (
    kullanici_id integer     not null references public.taraf_kullanici(id),
    kaynak       varchar(40) not null,        -- liste kaynağı adı ("icd", "ilac"...)
    kod          varchar(60) not null,        -- katalog anahtarı (ICD kodu)
    say          integer     not null default 1,
    son_tarih    timestamp   not null default now(),
    primary key (kullanici_id, kaynak, kod)
);

create index if not exists ix_kullanici_katalog_sik
    on public.kullanici_katalog (kullanici_id, kaynak, say desc);
create index if not exists ix_kullanici_katalog_son
    on public.kullanici_katalog (kullanici_id, kaynak, son_tarih desc);

comment on table public.kullanici_katalog is
    'Metin anahtarli kataloglarda (ICD...) kullanici bazli sik/son kullanim sayaci (461).';
