\set ON_ERROR_STOP on
-- ============================================================================
--  1213 — K28 geçmiş temizliği: denetim logundaki düz şifreler + sube artığı
--
--  Kod inceleme 30.10.2026 K28: entegrasyon sırları artık DB'de şifreli
--  (GizliMetin, API tarafında). Bu değişiklikten ÖNCE yazılmış iki iz kaldı:
--
--  1) islem_log (entegrasyon hesabı, tablo 951): ekleme / değişiklik / silme
--     logları şifreyi DÜZ METİN taşıyor ("sifre": " -> atlas154"). Yalnız şu
--     anahtarların düz değerleri '***' olur (şifreli 'enc1:' değerler ve diğer
--     alanlar aynen kalır): sifre, client_secret (ayarlar metni içinde dahil).
--     YEDEK ALINMAZ - yedek düz şifreyi saklamak olurdu; işlenen log id'leri
--     _yedek_islem_log_1213'e yazılır (değersiz). Silme logundaki şifre maskelenince
--     o kaydı "Geri Al" ile diriltmek şifreyi geri getirmez: ekrandan yeniden girilir.
--
--  2) sube.entegrator_sifre / test_sifre: 337 bunları entegrasyon_hesap'a TAŞIDI,
--     o tarihten beri hiçbir kod okumuyor. Yalnız KANITLI KOPYA temizlenir: aynı
--     şubede aynı kullanıcı adıyla e-Belge hesabı (EBELGE, aynı test/canlı) varsa.
--     Karşılığı olmayan satıra dokunulmaz, sayısı bildirilir.
-- ============================================================================
begin;

-- sube Delphi aktarımlı olabilir: satırın içeriği değil yalnız artık temizleniyor, salt-okur tetiği bu işlemde açık.
select set_config('gentegre.aktarim', '1', true);

create table if not exists public._yedek_islem_log_1213 (log_id bigint primary key, islem_tarihi timestamptz default now());

create or replace function pg_temp.maskele(v text) returns text language sql immutable as $$
    -- "eski -> yeni" biçiminde her iki taraf; boş ve 'enc1:' taraflar olduğu gibi.
    select string_agg(case when p = '' or p like 'enc1:%' then p else '***' end, ' -> ' order by i)
      from unnest(string_to_array(v, ' -> ')) with ordinality u(p, i)
$$;

create or replace function pg_temp.temizle(b jsonb) returns jsonb language plpgsql immutable as $$
declare
    k text;
    v jsonb;
    ic jsonb;
begin
    if jsonb_typeof(b) <> 'object' then return b; end if;
    for k, v in select * from jsonb_each(b) loop
        if k in ('sifre', 'client_secret') and jsonb_typeof(v) = 'string' then
            b := jsonb_set(b, array[k], to_jsonb(pg_temp.maskele(v #>> '{}')));
        elsif k = 'ayarlar' and jsonb_typeof(v) = 'string' and (v #>> '{}') like '%client_secret%' then
            -- ayarlar metin olarak loglanır: içindeki client_secret maskelenir ("a -> b" ise iki taraf ayrı).
            b := jsonb_set(b, array[k], to_jsonb((
                select string_agg(case when t like '{%' then
                         coalesce(pg_temp.temizle(t::jsonb)::text, t) else t end, ' -> ' order by i)
                  from unnest(string_to_array(v #>> '{}', ' -> ')) with ordinality u(t, i))));
        elsif jsonb_typeof(v) = 'object' then
            -- {"kart": {...}} / {"__detaylar": ...} sarmalı
            b := jsonb_set(b, array[k], pg_temp.temizle(v));
        end if;
    end loop;
    return b;
end $$;

do $$
declare
    n_log int;
    n_sube int;
    n_kalan int;
begin
    with hedef as (
        select id, bilgi, pg_temp.temizle(bilgi) as yeni
          from public.islem_log
         where tablo_id = 951
           and bilgi::text ~ '"(sifre|client_secret)"'
    ), yaz as (
        update public.islem_log l set bilgi = h.yeni
          from hedef h
         where l.id = h.id and h.yeni is distinct from h.bilgi
        returning l.id
    ), kayit as (
        insert into public._yedek_islem_log_1213 (log_id) select id from yaz on conflict do nothing returning 1
    )
    select count(*) into n_log from kayit;

    -- sube artığı: yalnız entegrasyon_hesap'ta karşılığı olanlar
    update public.sube s set entegrator_sifre = ''
     where coalesce(s.entegrator_sifre, '') <> ''
       and exists (select 1 from public.entegrasyon_hesap h
                    where h.kod = 'EBELGE' and h.sube_id = s.id and coalesce(h.test_mi, 0) = 0
                      and h.kullanici_adi = s.entegrator_kullanici and coalesce(h.sifre, '') <> '');
    get diagnostics n_sube = row_count;
    update public.sube s set test_sifre = ''
     where coalesce(s.test_sifre, '') <> ''
       and exists (select 1 from public.entegrasyon_hesap h
                    where h.kod = 'EBELGE' and h.sube_id = s.id and coalesce(h.test_mi, 0) = 1
                      and h.kullanici_adi = s.test_kullanici and coalesce(h.sifre, '') <> '');
    get diagnostics n_kalan = row_count;
    n_sube := n_sube + n_kalan;

    select count(*) into n_kalan from public.sube
     where coalesce(entegrator_sifre, '') <> '' or coalesce(test_sifre, '') <> '';

    raise notice '1213: % log satiri maskelendi, % sube sifre artigi temizlendi, % sube satirinda karsiligi olmayan sifre kaldi',
                 n_log, n_sube, n_kalan;
end $$;

commit;
