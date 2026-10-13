-- =============================================================================
--  1086  DELPHI AKTARIMI - ADIM 4: PAKET UYGULAYICI   (dokuman/18 §11)
--
--  Ajan (müşteri sunucusunda) Delphi Change Tracking değişikliklerini paket
--  olarak /api/aktarim/paket'e yollar; API bu fonksiyonu çağırır.
--
--  Paket:  {"paket": "<ajanın paket kimliği>",
--           "V": {TABLO: ct_versiyon, ...},          -- paket hangi versiyona kadar
--           "U": {TABLO: [satır, ...]}, "D": {TABLO: [id | {anahtar}, ...]}}
--
--  * Sıra sunucuda: tanımlar önce, kaynak türetilenden önce (fn_aktarim_adimlari).
--    Ajan tabloları istediği gibi paketleyebilir.
--  * Kurum başına tek eşzamanlı uygulama (advisory lock, işlem sonuna kadar).
--  * Adım adım (savepoint): bir adım hata verirse O ADIM ve SONRAKİLER uygulanmaz
--    (sonrakiler ona bağlı - hatalı cari varken belge yazılırsa carisiz kalırdı),
--    önceki adımlar kalır. Hata aktarim_hata'ya (adım başına tek açık kayıt,
--    deneme sayacı); adım sonra başarılı olunca kapanır.
--  * Versiyon (aktarim_durum) yalnız uygulanan adımların tabloları için ilerler,
--    geri gitmez. Ajan kaldığı yeri /api/aktarim/durum'dan okur; hatalı tablonun
--    versiyonu ilerlemediği için aynı değişiklikleri tekrar yollar.
--  * İdempotent: tamamlanmış paket kimliği ikinci kez gelirse yeniden
--    uygulanmaz, kayıtlı sonuç döner. Uygulansa da zararsızdır (upsert).
--  * Bilinmeyen tablo -> 'AKTARIM_TABLO' hatası, hiçbir şey yazılmaz.
-- =============================================================================

begin;

-- ------------------------------------------------------------------ ajan ----
-- Anahtar düz saklanmaz: sha256 özeti. Ajan anahtarı yalnız üretildiği an görülür.
create table if not exists public.aktarim_ajan (
    id           serial primary key,
    ad           varchar(100) not null,
    anahtar_ozet char(64)     not null unique,
    aktif        smallint     not null default 1,
    olusturma    timestamptz  not null default now(),
    son_nabiz    timestamptz,
    surum        varchar(40)
);

create table if not exists public.aktarim_durum (
    tablo        varchar(40) primary key,
    versiyon     bigint      not null default 0,
    son_paket    timestamptz,
    son_paket_id bigint
);

create table if not exists public.aktarim_paket (
    id        bigserial primary key,
    ajan_id   integer     not null references public.aktarim_ajan (id),
    paket_no  varchar(64) not null,
    alinma    timestamptz not null default now(),
    sure_ms   integer,
    durum     smallint    not null,              -- 1 tamam, 2 bir adım hatalı
    ozet      jsonb,                             -- tablo başına U / D sayısı
    sonuc     jsonb,
    unique (ajan_id, paket_no)
);

create table if not exists public.aktarim_hata (
    id        bigserial primary key,
    ajan_id   integer      not null references public.aktarim_ajan (id),
    adim      varchar(40)  not null,
    tablolar  text[]       not null,
    paket_no  varchar(64),
    mesaj     text         not null,
    ayrinti   text,
    ham       jsonb,                             -- adımın tablolarının U / D kısmı
    deneme    integer      not null default 1,
    ilk_zaman timestamptz  not null default now(),
    son_zaman timestamptz  not null default now(),
    cozulme   timestamptz
);
create unique index if not exists ux_aktarim_hata_acik on public.aktarim_hata (adim) where cozulme is null;

-- ------------------------------------------------------------ adım sırası ---
-- Tek kaynak: hangi fonksiyon hangi Delphi tablolarını işler, hangi sırayla.
create or replace function public.fn_aktarim_adimlari()
returns table (sira int, fonksiyon text, tablolar text[]) language sql immutable as $$
    values (1,  'fn_aktar_depo',           array['DEPOLAR']),
           (2,  'fn_aktar_doviz',          array['DOVIZ']),
           (3,  'fn_aktar_masraf_merkezi', array['SRMMERKEZI']),
           (4,  'fn_aktar_cari',           array['REHBER', 'REHBERILETISIM', 'REHBERBILGI']),
           (5,  'fn_aktar_proje',          array['PROJELER']),
           (6,  'fn_aktar_kalem',          array['MASRAFGELIR', 'FIYATLAR']),
           (7,  'fn_aktar_stok',           array['STOKLAR', 'STOKBARKOD', 'STOKFIYAT', 'STOKSERILOT']),
           (8,  'fn_aktar_hesap',          array['KASALAR', 'BANKAHESAPLAR', 'POS', 'KREDIKARTI', 'KREDILER']),
           (9,  'fn_aktar_is_merkezi',     array['LOKASYON']),
           (10, 'fn_aktar_recete',         array['URETIMRECETE', 'URETIMRECETEDETAY', 'URETIMRECETEOPR']),
           (11, 'fn_aktar_stok_durum',     array['STOKDURUM']),
           (12, 'fn_aktar_belge',          array['FATBASLIK', 'FATURA', 'STOKIZLEME']),
           (13, 'fn_aktar_kasa',           array['KASA'])
$$;

-- ------------------------------------------------------------- yeni ajan ---
-- Düz anahtarı döner (bir kez); tabloda yalnız özeti kalır.
create or replace function public.fn_aktarim_ajan_ekle(p_ad text)
returns text language plpgsql as $$
declare v text := replace(gen_random_uuid()::text, '-', '') || replace(gen_random_uuid()::text, '-', '');
begin
    insert into public.aktarim_ajan (ad, anahtar_ozet)
    values (coalesce(nullif(btrim(p_ad), ''), 'Aktarım ajanı'), encode(sha256(convert_to(v, 'UTF8')), 'hex'));
    return v;
end $$;

create or replace function public.fn_aktarim_ajan_bul(p_anahtar text)
returns integer language sql stable as $$
    select a.id from public.aktarim_ajan a
     where a.aktif = 1 and coalesce(p_anahtar, '') <> ''
       and a.anahtar_ozet = encode(sha256(convert_to(p_anahtar, 'UTF8')), 'hex')
$$;

-- ---------------------------------------------------------------- paket ---
create or replace function public.fn_aktar_paket(p_ajan integer, p jsonb)
returns jsonb language plpgsql as $$
declare
    v_no      varchar(64) := left(coalesce(nullif(btrim(p->>'paket'), ''), gen_random_uuid()::text), 64);
    v_bas     timestamptz := clock_timestamp();
    v_eski    record;
    v_bilinmeyen text;
    v_adim    record;
    v_parca   jsonb;
    v_sonuc   jsonb := '{}';
    v_tamam   text[] := '{}';
    v_hata    jsonb;
    v_mesaj   text;
    v_ayrinti text;
    v_paket_id bigint;
    v_tablolar text[];
begin
    perform pg_advisory_xact_lock(hashtext('gentegre.aktarim'));

    select id, durum, sonuc into v_eski from public.aktarim_paket where ajan_id = p_ajan and paket_no = v_no;
    if found and v_eski.durum = 1 then
        return v_eski.sonuc || jsonb_build_object('tekrar', true);
    end if;

    select string_agg(k, ', ' order by k) into v_bilinmeyen
      from (select jsonb_object_keys(coalesce(p->'U', '{}')) k
            union select jsonb_object_keys(coalesce(p->'D', '{}'))
            union select jsonb_object_keys(coalesce(p->'V', '{}'))) x
     where not exists (select 1 from public.fn_aktarim_adimlari() a where x.k = any (a.tablolar));
    if v_bilinmeyen is not null then
        raise exception 'AKTARIM_TABLO: bilinmeyen tablo %', v_bilinmeyen;
    end if;

    for v_adim in select * from public.fn_aktarim_adimlari() order by sira loop
        -- Adımın tabloları pakette yoksa çağrılmaz; yalnız versiyonu gelmişse de "tamam".
        if not (coalesce(p->'U', '{}') ?| v_adim.tablolar or coalesce(p->'D', '{}') ?| v_adim.tablolar) then
            v_tamam := v_tamam || v_adim.tablolar;
            continue;
        end if;
        begin
            execute format('select public.%I($1)', v_adim.fonksiyon) into v_parca using p;
            v_sonuc := v_sonuc || jsonb_build_object(v_adim.fonksiyon, v_parca);
            v_tamam := v_tamam || v_adim.tablolar;
            update public.aktarim_hata set cozulme = now() where adim = v_adim.fonksiyon and cozulme is null;
        exception when others then
            get stacked diagnostics v_mesaj = message_text, v_ayrinti = pg_exception_context;
            v_hata := jsonb_build_object('adim', v_adim.fonksiyon, 'tablolar', to_jsonb(v_adim.tablolar),
                                         'mesaj', v_mesaj);
            insert into public.aktarim_hata as h (ajan_id, adim, tablolar, paket_no, mesaj, ayrinti, ham)
            values (p_ajan, v_adim.fonksiyon, v_adim.tablolar, v_no, v_mesaj, v_ayrinti,
                    jsonb_build_object(
                        'U', (select coalesce(jsonb_object_agg(k, v), '{}') from jsonb_each(coalesce(p->'U', '{}')) e(k, v)
                               where k = any (v_adim.tablolar)),
                        'D', (select coalesce(jsonb_object_agg(k, v), '{}') from jsonb_each(coalesce(p->'D', '{}')) e(k, v)
                               where k = any (v_adim.tablolar))))
            on conflict (adim) where cozulme is null
            do update set deneme = h.deneme + 1, son_zaman = now(), paket_no = excluded.paket_no,
                          mesaj = excluded.mesaj, ayrinti = excluded.ayrinti, ham = excluded.ham,
                          ajan_id = excluded.ajan_id;
            exit;   -- sonraki adımlar buna bağlı
        end;
    end loop;

    v_sonuc := jsonb_build_object('paket', v_no, 'sonuc', v_sonuc, 'hata', v_hata,
                                  'ilerleyen', (select coalesce(jsonb_agg(k order by k), '[]')
                                                  from jsonb_object_keys(coalesce(p->'V', '{}')) k
                                                 where k = any (v_tamam)));

    insert into public.aktarim_paket as x (ajan_id, paket_no, sure_ms, durum, ozet, sonuc)
    values (p_ajan, v_no, (extract(epoch from clock_timestamp() - v_bas) * 1000)::int,
            case when v_hata is null then 1 else 2 end,
            (select jsonb_object_agg(t, jsonb_build_object(
                        'U', coalesce(jsonb_array_length(p->'U'->t), 0),
                        'D', coalesce(jsonb_array_length(p->'D'->t), 0)))
               from (select jsonb_object_keys(coalesce(p->'U', '{}')) t
                     union select jsonb_object_keys(coalesce(p->'D', '{}'))) y),
            v_sonuc)
    on conflict (ajan_id, paket_no)
    do update set alinma = now(), sure_ms = excluded.sure_ms, durum = excluded.durum,
                  ozet = excluded.ozet, sonuc = excluded.sonuc
    returning id into v_paket_id;

    -- Versiyon: yalnız uygulanan adımların tabloları, geri gitmez.
    insert into public.aktarim_durum as d (tablo, versiyon, son_paket, son_paket_id)
    select k, (v #>> '{}')::bigint, now(), v_paket_id
      from jsonb_each(coalesce(p->'V', '{}')) e(k, v)
     where k = any (v_tamam)
    on conflict (tablo) do update
       set versiyon = greatest(d.versiyon, excluded.versiyon), son_paket = now(), son_paket_id = v_paket_id;

    return v_sonuc;
end $$;

comment on function public.fn_aktar_paket(integer, jsonb) is
    '1086: Delphi aktarım paketi - sıralı, adım başına savepoint, hata kuyruğu, CT versiyonu (dokuman/18 §11).';

commit;
