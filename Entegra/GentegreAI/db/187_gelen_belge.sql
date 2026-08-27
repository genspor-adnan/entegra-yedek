-- ============================================================================
--  Gentegre AI — GELEN e-BELGE (kutu / inbox)
--  187_gelen_belge.sql
--
--  Simdiye kadar yalniz GIDEN taraf vardi: hazirla / gonder / durum sorgula.
--  Alicinin bize kestigi e-Faturalar hic gorunmuyordu; ne geldigini gormek,
--  UBL'ini indirmek ve KABUL/RED yaniti vermek icin bu dosya:
--
--    * e_belge (yon = 2) kutunun kaydi olur - ayri tablo ACILMAZ, giden ile
--      ayni yasam dongusu (uuid tekil, api_json ham yanit, durum kodlari).
--    * Kutu satirinin listede gosterilecek alanlari kolon olarak eklenir
--      (tarih/tutar/gonderici/profil): her listede JSON ayiklamak yavas ve
--      filtrelenemez olurdu.
--    * fn_gelen_belge_kaydet: entegratorden gelen satiri UUID'ye gore upsert
--      eder - kutu tekrar tekrar cekilebilir, mukerrer kayit olusmaz.
--    * fn_gelen_belge_yanit_yaz: kabul/red yanitindan sonra durumu isler.
--
--  DURUM KODLARI (gelen):
--    100 kutuda (yanit bekliyor) · 101 kabul edildi · 102 reddedildi
--    103 yanit gerekmez (e-Arsiv / temel fatura)
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.e_belge
    add column if not exists belge_tarihi      date,
    add column if not exists tutar             numeric(19,2) not null default 0,
    add column if not exists vergi_tutar       numeric(19,2) not null default 0,
    add column if not exists para_birimi       varchar(3)   not null default 'TRY',
    add column if not exists profil            varchar(30)  not null default '',
    add column if not exists senaryo_adi       varchar(30)  not null default '',
    add column if not exists gonderici_unvan   varchar(200) not null default '',
    add column if not exists satir_sayisi      integer      not null default 0,
    add column if not exists okundu            smallint     not null default 0,
    add column if not exists zarf_id           varchar(60)  not null default '',
    add column if not exists gib_zarf_kodu     varchar(10)  not null default '',
    add column if not exists yanit_aciklama    varchar(500) not null default '',
    -- Entegratorun KENDI kayit numarasi: icerik indirme ve yanit ucları
    --   UUID degil bu id'yi istiyor (izibiz /v1/einvoices/inbox/download/ubl).
    add column if not exists entegrator_kayit  varchar(40)  not null default '';

comment on column public.e_belge.entegrator_kayit is
  'Entegratorun kendi kayit numarasi (187): icerik indirme / yanit uclari bunu ister.';
comment on column public.e_belge.okundu is
  'Gelen belge kullanicida acildi mi (187).';

create index if not exists ix_e_belge_gelen
    on public.e_belge (yon, durum, belge_tarihi desc)
    where yon = 2;

-- ---------------------------------------------------------------------------
--  Kutu satirini kaydet (upsert).
--
--  UUID GIB'de tekil oldugu icin cakisma anahtari odur. Var olan satirda
--  DURUM ve yanit alanlari tazelenir; ubl_xml gibi bizim indirdigimiz veri
--  KORUNUR (entegrator listesi icerik dondurmez, ezmemeli).
-- ---------------------------------------------------------------------------
create or replace function public.fn_gelen_belge_kaydet(p_satir jsonb,
                                                        p_sube_id integer,
                                                        p_entegrator varchar,
                                                        p_kullanici integer)
returns table (e_belge_id bigint, yeni boolean)
language plpgsql as $$
declare
    v_uuid    varchar(50)  := nullif(btrim(p_satir->>'uuid'), '');
    v_vkno    varchar(20)  := coalesce(btrim(p_satir->>'gondericiVkno'), '');
    v_durum   smallint;
    v_yanit   varchar(100) := coalesce(btrim(p_satir->>'yanitKodu'), '');
    v_taraf   integer;
    v_id      bigint;
    v_yeni    boolean := false;
begin
    if v_uuid is null then
        raise exception 'Gelen belgede UUID yok; kayıt edilemez.';
    end if;

    -- Gonderici carimiz mi: VKN ile eslesir. Yoksa null kalir - liste yine
    --   gosterir (unvan JSON'dan gelir), kullanici isterse cari acar.
    select t.id into v_taraf
      from public.taraf t
     where coalesce(btrim(t.vkno), '') = v_vkno and v_vkno <> ''
     order by t.id limit 1;

    -- YANIT DURUMU: entegratorun kodu bizim durum kodumuza cevrilir.
    v_durum := case upper(v_yanit)
                 when 'ACCEPTED' then 101
                 when 'APPROVED' then 101
                 when 'REJECTED' then 102
                 when 'DECLINED' then 102
                 else case when upper(coalesce(p_satir->>'profil', '')) = 'TEMELFATURA'
                             then 103 else 100 end
               end;

    insert into public.e_belge (
        belge_id, taraf_id, belge_turu, yon, uuid, belge_no,
        gonderici_alias, alici_alias, durum, api_json,
        gib_durum_kodu, gib_durum_aciklama, yanit_durum_kodu, yanit_durum_adi,
        sube_id, gonderici_vkno, entegrator,
        belge_tarihi, tutar, vergi_tutar, para_birimi, profil, senaryo_adi,
        gonderici_unvan, satir_sayisi, zarf_id, gib_zarf_kodu, entegrator_kayit,
        ekleyen)
    values (
        null, v_taraf,
        coalesce((p_satir->>'belgeTuru')::smallint, 1), 2, v_uuid,
        coalesce(btrim(p_satir->>'belgeNo'), ''),
        coalesce(btrim(p_satir->>'gondericiAlias'), ''),
        coalesce(btrim(p_satir->>'aliciAlias'), ''),
        v_durum, coalesce(p_satir->>'ham', ''),
        coalesce(btrim(p_satir->>'gibKod'), ''),
        coalesce(btrim(p_satir->>'gibAciklama'), ''),
        v_yanit, coalesce(btrim(p_satir->>'yanitAdi'), ''),
        p_sube_id, v_vkno, coalesce(p_entegrator, ''),
        nullif(btrim(p_satir->>'belgeTarihi'), '')::date,
        coalesce((p_satir->>'tutar')::numeric, 0),
        coalesce((p_satir->>'vergiTutar')::numeric, 0),
        coalesce(nullif(btrim(p_satir->>'paraBirimi'), ''), 'TRY'),
        coalesce(btrim(p_satir->>'profil'), ''),
        coalesce(btrim(p_satir->>'senaryoAdi'), ''),
        coalesce(btrim(p_satir->>'gondericiUnvan'), ''),
        coalesce((p_satir->>'satirSayisi')::integer, 0),
        coalesce(btrim(p_satir->>'zarfId'), ''),
        coalesce(btrim(p_satir->>'gibZarfKodu'), ''),
        coalesce(btrim(p_satir->>'entegratorKayit'), ''),
        p_kullanici)
    on conflict (uuid) where uuid is not null do update
       set durum              = excluded.durum,
           yanit_durum_kodu   = excluded.yanit_durum_kodu,
           yanit_durum_adi    = excluded.yanit_durum_adi,
           gib_durum_kodu     = excluded.gib_durum_kodu,
           gib_durum_aciklama = excluded.gib_durum_aciklama,
           api_json           = excluded.api_json,
           taraf_id           = coalesce(public.e_belge.taraf_id, excluded.taraf_id),
           entegrator_kayit   = case when excluded.entegrator_kayit <> ''
                                     then excluded.entegrator_kayit
                                     else public.e_belge.entegrator_kayit end,
           degistiren         = p_kullanici,
           degistirme_tarihi  = now()::timestamp
    returning public.e_belge.id, (xmax = 0) into v_id, v_yeni;

    return query select v_id, v_yeni;
end $$;

comment on function public.fn_gelen_belge_kaydet(jsonb, integer, varchar, integer) is
  'Entegrator kutu satirini UUID uzerinden upsert eder (187); kutu tekrar cekilince mukerrer olmaz.';

-- ---------------------------------------------------------------------------
--  Kabul / red yaniti islendikten sonra durumu yaz.
-- ---------------------------------------------------------------------------
create or replace function public.fn_gelen_belge_yanit_yaz(p_e_belge_id bigint,
                                                           p_kabul boolean,
                                                           p_aciklama varchar,
                                                           p_kullanici integer)
returns void language sql as $$
    update public.e_belge
       set durum             = case when p_kabul then 101 else 102 end,
           yanit_durum_kodu  = case when p_kabul then 'ACCEPTED' else 'REJECTED' end,
           yanit_durum_adi   = case when p_kabul then 'Kabul edildi' else 'Reddedildi' end,
           yanit_aciklama    = coalesce(p_aciklama, ''),
           degistiren        = p_kullanici,
           degistirme_tarihi = now()::timestamp
     where id = p_e_belge_id and yon = 2;
$$;

-- ---------------------------------------------------------------------------
--  Gelen belge durum adi (liste rozeti).
-- ---------------------------------------------------------------------------
create or replace function public.fn_gelen_durum_adi(p_durum smallint)
returns varchar language sql immutable as $$
    select case p_durum
             when 100 then 'Yanıt bekliyor'
             when 101 then 'Kabul'
             when 102 then 'Red'
             when 103 then 'Yanıt gerekmez'
             else 'Bilinmiyor' end::varchar
$$;

do $$
begin
    raise notice '187 tamam: gelen e-Belge kutusu (e_belge yon=2) + kaydet/yanit fonksiyonlari.';
end $$;
