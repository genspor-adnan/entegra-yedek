-- ============================================================================
--  431 - DOKÜMAN KATEGORİSİ (ağaç) + tip ikonu
--
--  Kullanıcı: "Doküman türü yerine Doküman Kategorisi adıyla olsun ve
--  hizmet/stok gibi bir standart gelişsin, ağaç yapısında olsun."
--
--  YAPILAN: `dokuman_turu` tablosu `dokuman_kategori` olarak yeniden
--  adlandırıldı, ÜST KATEGORİ (ust_id) ve YOL (yol) eklendi. Stok/hizmet
--  kategorisiyle aynı desen: sınırsız derinlik, kod + ad, "yol" gösterimi.
--
--  NEDEN AYRI TABLO, `kategori` DEĞİL: doküman kategorisi yalnız bir etiket
--  değil, DAVRANIŞ taşıyor - sürümlü mü, hangi onay akışı, hangi gizlilik
--  sınıfı. Bunları `kategori` tablosuna eklemek, stok ve hizmet kategorilerine
--  hiç kullanmayacakları üç kolon takmak olurdu. Ekran deseni aynı, tablo ayrı.
--
--  YENİDEN ADLANDIRMA, YENİ TABLO DEĞİL: mevcut 8 kategori ve onlara bağlı
--  dokümanlar korunur. Yeni tablo açıp veriyi kopyalamak, bağları kırardı.
-- ============================================================================

-- ---------------------------------------------------------------------------
--  1) TABLO VE KOLON ADLARI
-- ---------------------------------------------------------------------------
do $$
begin
    if exists (select 1 from information_schema.tables
                where table_schema = 'public' and table_name = 'dokuman_turu')
       and not exists (select 1 from information_schema.tables
                        where table_schema = 'public' and table_name = 'dokuman_kategori')
    then
        alter table public.dokuman_turu rename to dokuman_kategori;
    end if;

    if exists (select 1 from information_schema.columns
                where table_name = 'dokuman' and column_name = 'belge_turu_id')
    then
        alter table public.dokuman rename column belge_turu_id to kategori_id;
    end if;

    if exists (select 1 from information_schema.columns
                where table_name = 'dokuman_klasor' and column_name = 'varsayilan_tur_id')
    then
        alter table public.dokuman_klasor
            rename column varsayilan_tur_id to varsayilan_kategori_id;
    end if;
end $$;

-- ---------------------------------------------------------------------------
--  2) AĞAÇ: üst kategori + yol
--
--  YOL SAKLANIR (türetilmez): liste ve seçici her satırda "Kalite › Prosedür ›
--  Talimat" göstermek zorunda; her okumada özyinelemeli sorgu çalıştırmak,
--  100 satırlık bir gridde 100 ağaç yürüyüşü demekti. Tetik güncel tutar.
-- ---------------------------------------------------------------------------
alter table public.dokuman_kategori
    add column if not exists ust_id integer references public.dokuman_kategori(id),
    add column if not exists yol    varchar(300) not null default '',
    add column if not exists sira   smallint     not null default 0;

create index if not exists ix_dokuman_kategori_ust
    on public.dokuman_kategori(ust_id) where ust_id is not null;

-- KENDİ ATASI OLAMAZ: döngü kurulursa yol hesabı sonsuza girer ve ağaç
--   çizilemez. Kontrol tetikte - CHECK kısıtı özyinelemeli sorgu yazamaz.
create or replace function public.fn_dokuman_kategori_yol()
returns trigger language plpgsql as $$
declare
    v_yol  text := new.ad;
    v_ust  integer := new.ust_id;
    v_adim integer := 0;
begin
    while v_ust is not null loop
        v_adim := v_adim + 1;
        if v_adim > 20 or v_ust = new.id then
            raise exception 'Doküman kategorisi kendi altına taşınamaz.'
                using errcode = 'GK422';
        end if;
        select k.ad || ' › ' || v_yol, k.ust_id into v_yol, v_ust
          from public.dokuman_kategori k where k.id = v_ust;
        exit when not found;
    end loop;
    new.yol := left(v_yol, 300);
    return new;
end $$;

drop trigger if exists trg_dokuman_kategori_yol on public.dokuman_kategori;
create trigger trg_dokuman_kategori_yol
    before insert or update of ad, ust_id on public.dokuman_kategori
    for each row execute function public.fn_dokuman_kategori_yol();

-- ALT AĞAÇ YOLLARI: üst kategorinin adı değişince altındakiler de yenilenir.
--   Tetik yalnız kendi satırını görür; alt ağacı tazelemek ayrı bir adım.
--
--   TETİKTE "update of yol" YAZILMAZ: PostgreSQL'de o cümle UPDATE
--   DEYİMİNDE SAYILAN kolonlara bakar, tetiğin kendi yazdığına değil.
--   `update ... set ad = 'X'` deyiminde yol geçmediği için tetik hiç
--   çalışmıyordu ve alt kategorilerin yolu eski adla kalıyordu.
create or replace function public.fn_dokuman_kategori_alt_yol()
returns trigger language plpgsql as $$
begin
    if new.yol is distinct from old.yol then
        update public.dokuman_kategori k
           set ad = k.ad            -- tetiği tetikler, yol yeniden hesaplanır
         where k.ust_id = new.id;
    end if;
    return null;
end $$;

drop trigger if exists trg_dokuman_kategori_alt_yol on public.dokuman_kategori;
create trigger trg_dokuman_kategori_alt_yol
    after update on public.dokuman_kategori
    for each row when (old.yol is distinct from new.yol)
    execute function public.fn_dokuman_kategori_alt_yol();

-- Mevcut satırların yolu doldurulur (kök kategoriler: yol = ad).
update public.dokuman_kategori set ad = ad where yol = '';

-- ---------------------------------------------------------------------------
--  3) LOOKUP GÖRÜNÜMÜ - ad yerine YOL gösterir: aynı adlı iki alt kategori
--     ("Sözleşme") ancak yoluyla ayırt edilir.
-- ---------------------------------------------------------------------------
drop view if exists public.v_dokuman_turu_lookup;
drop view if exists public.v_dokuman_kategori_lookup;
create view public.v_dokuman_kategori_lookup as
-- Kod alani `kisaltma`: tablo bu adla dogdu (419), yeniden adlandirmak
--   kazanc getirmezdi - gorunum ikisini de dogru adla sunuyor.
select t.id,
       coalesce(nullif(t.kisaltma, ''), t.id::text) as kod,
       coalesce(nullif(t.yol, ''), t.ad)            as ad,
       t.aktif
  from public.dokuman_kategori t;

-- ---------------------------------------------------------------------------
--  4) DOSYA TİPİ - listede ikon olarak gösterilir (pdf/doc/xls/png…).
--
--  Uzantı ve içerik tipi BİRLİKTE okunur: içerik tipi bazen
--  "application/octet-stream" geliyor (tarayıcı bilmiyorsa), uzantı ise
--  dosya adı değiştirilirse kaybolabiliyor. İkisinden biri yeterli.
-- ---------------------------------------------------------------------------
create or replace function public.fn_dokuman_tipi(p_ad text, p_icerik_tipi text)
returns text language sql immutable as $$
    select case
        when lower(coalesce(p_ad, '')) ~ '\.pdf$'                      then 'pdf'
        when coalesce(p_icerik_tipi, '') = 'application/pdf'           then 'pdf'
        when lower(coalesce(p_ad, '')) ~ '\.(doc|docx|odt|rtf)$'       then 'doc'
        when coalesce(p_icerik_tipi, '') like '%word%'                 then 'doc'
        when lower(coalesce(p_ad, '')) ~ '\.(xls|xlsx|ods|csv)$'       then 'xls'
        when coalesce(p_icerik_tipi, '') like '%excel%'
          or coalesce(p_icerik_tipi, '') like '%spreadsheet%'          then 'xls'
        when lower(coalesce(p_ad, '')) ~ '\.(ppt|pptx|odp)$'           then 'ppt'
        when lower(coalesce(p_ad, '')) ~ '\.(png|jpg|jpeg|gif|bmp|webp|heic)$' then 'resim'
        when coalesce(p_icerik_tipi, '') like 'image/%'                then 'resim'
        when lower(coalesce(p_ad, '')) ~ '\.(zip|rar|7z|gz|tar)$'      then 'arsiv'
        when lower(coalesce(p_ad, '')) ~ '\.(txt|log|md|json|xml)$'    then 'metin'
        when coalesce(p_icerik_tipi, '') like 'text/%'                 then 'metin'
        when coalesce(p_icerik_tipi, '') like 'video/%'                then 'video'
        when coalesce(p_icerik_tipi, '') like 'audio/%'                then 'ses'
        else 'diger'
    end;
$$;

-- ---------------------------------------------------------------------------
--  5) SİLME KORUMASI - kullanılan kategori ve klasör silinemez.
--
--  Kural ekranda (KartKatalogu.SilmeEngelleri) da var; burada VERİTABANI
--  düzeyinde de duruyor çünkü kayıt yalnız ekrandan silinmiyor: göç ve
--  onarım betikleri de aynı korumaya tabi olmalı. FK "no action" ile
--  silinme reddedilir, kayıtlar sahipsiz kalmaz.
-- ---------------------------------------------------------------------------
do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'fk_dokuman_kategori') then
        alter table public.dokuman
            add constraint fk_dokuman_kategori
            foreign key (kategori_id) references public.dokuman_kategori(id);
    end if;

    if not exists (select 1 from pg_constraint
                    where conname = 'fk_dokuman_klasor_varsayilan_kategori') then
        alter table public.dokuman_klasor
            add constraint fk_dokuman_klasor_varsayilan_kategori
            foreign key (varsayilan_kategori_id) references public.dokuman_kategori(id);
    end if;

    if not exists (select 1 from pg_constraint where conname = 'fk_dokuman_klasor') then
        alter table public.dokuman
            add constraint fk_dokuman_klasor
            foreign key (klasor_id) references public.dokuman_klasor(id);
    end if;
end $$;

comment on table public.dokuman_kategori is
    'Dokuman kategorisi (431, eski dokuman_turu): agac yapili; surumlu/akis/gizlilik davranisini tasir.';

-- Onay akisi secici: kategori kartinda "hangi akistan gecsin" alani.
drop view if exists public.v_dokuman_akis_lookup;
create view public.v_dokuman_akis_lookup as
select a.id, a.id::text as kod, a.ad, a.aktif
  from public.dokuman_akis a;

-- ---------------------------------------------------------------------------
--  6) KLASÖR YOLU - kategoriyle aynı kural.
--
--  Klasör kartından eklenen klasörün `yol` alanı BOŞ kalıyordu (419'da yolu
--  yükleme ucu dolduruyordu, kart yoktu). Sol paneldeki ağaç ve listedeki
--  "Klasör" kolonu bu alanı okur - boş kalınca klasör görünmez oluyordu.
-- ---------------------------------------------------------------------------
create or replace function public.fn_dokuman_klasor_yol()
returns trigger language plpgsql as $$
declare
    v_yol  text := new.ad;
    v_ust  integer := new.ust_id;
    v_adim integer := 0;
begin
    while v_ust is not null loop
        v_adim := v_adim + 1;
        if v_adim > 20 or v_ust = new.id then
            raise exception 'Klasör kendi altına taşınamaz.' using errcode = 'GK422';
        end if;
        select k.ad || ' › ' || v_yol, k.ust_id into v_yol, v_ust
          from public.dokuman_klasor k where k.id = v_ust;
        exit when not found;
    end loop;
    new.yol := left(v_yol, 300);
    return new;
end $$;

drop trigger if exists trg_dokuman_klasor_yol on public.dokuman_klasor;
create trigger trg_dokuman_klasor_yol
    before insert or update of ad, ust_id on public.dokuman_klasor
    for each row execute function public.fn_dokuman_klasor_yol();

create or replace function public.fn_dokuman_klasor_alt_yol()
returns trigger language plpgsql as $$
begin
    update public.dokuman_klasor k set ad = k.ad where k.ust_id = new.id;
    return null;
end $$;

drop trigger if exists trg_dokuman_klasor_alt_yol on public.dokuman_klasor;
create trigger trg_dokuman_klasor_alt_yol
    after update on public.dokuman_klasor
    for each row when (old.yol is distinct from new.yol)
    execute function public.fn_dokuman_klasor_alt_yol();

-- Yolu bos kalmis klasorler onarilir.
update public.dokuman_klasor set ad = ad where coalesce(yol, '') = '';
