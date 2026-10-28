-- =============================================================================
--  1197  HİZMET CİNSİYETİ: KESİN / İSTİSNALI
--
--  Kullanıcı (27.10.2026): "bazı tetkikler kesin erkek ya da kadın olsun.. bazılarına da ör. meme ekrandan
--  sorsun", "obstetrik kesin kadındır.. erkeğe eklenemez", "prostat sadece erkektir", "doğum kesin kadındır",
--  "yeni alan ekleme", "cinsiyete İstisnalı Kadın ve İstisnalı Erkek de eklenebilir".
--  Hizmet kartının MEVCUT Cinsiyet alanı (482) iki seçenekle genişler - yeni kolon yok:
--    0 Farketmez · 1 Yalnız Erkek · 2 Yalnız Kadın        (1-2 KESİN: gerekçe kabul edilmez)
--    3 İstisnalı Erkek · 4 İstisnalı Kadın                 (SORARAK: ekran uyarır, gerekçe yazılırsa kayda geçer)
--  1196'nın işaretlediği obstetrik / doğum / prostat / testis kalemleri KESİN kalır. Meme kalemleri (cinsiyeti
--  girilmemiş olanlar) İstisnalı Kadın olur (erkekte meme tetkiki / jinekomasti); kulak memesi, jinekomasti,
--  meme dışı bölge, BRCA dışarıda. Doğum sonrası tüp ligasyonu / epizyotomi kesin kadın. Kurumun elle girdiği
--  cinsiyete dokunulmaz; değişenin eski hali hizmet_cinsiyet_yedek_1197'de. İdempotent.
--  Radyoloji istemi (hekim istemi) gerekçe kolonu taşımaz: İSTİSNALI hizmette istem engellenmez - gerekçe ücret
--  satırında istenir.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

comment on column public.hizmet.cinsiyet is
  'Hizmetin cinsiyet kısıtı (482/1197): 0 farketmez · 1 yalnız erkek · 2 yalnız kadın (kesin) · 3 istisnalı erkek · 4 istisnalı kadın (gerekçeyle geçer).';

create table if not exists public.hizmet_cinsiyet_yedek_1197 (
  hizmet_id integer primary key,
  eski_cinsiyet smallint not null,
  yeni_cinsiyet smallint not null,
  tarih timestamptz not null default now()
);

with s as (
  select id,
         case when lower(ad) ~ '(postpartum|tüp ligasyon|epizyotomi)' then 2
              when lower(ad) ~ '(\mmeme|mamografi|mammografi|mammo)'
                   and lower(ad) !~ '(kulak meme|jinekomasti|meme dışı|brca)' then 4
         end::smallint as yeni
    from public.hizmet where cinsiyet = 0
), yedek as (
  insert into public.hizmet_cinsiyet_yedek_1197 (hizmet_id, eski_cinsiyet, yeni_cinsiyet)
  select id, 0, yeni from s where yeni is not null
  on conflict (hizmet_id) do nothing
  returning hizmet_id, yeni_cinsiyet
)
update public.hizmet h set cinsiyet = y.yeni_cinsiyet
  from yedek y where h.id = y.hizmet_id and h.cinsiyet = 0;

-- ------------------------------------------------------------- kural ---
-- İstisnalı kodlar (3/4) kuralda erkek / kadın sayılır.
create or replace function public.fn_hizmet_uygunluk(
    p_hizmet_id integer,
    p_taraf_id  integer,
    p_tarih     date default current_date)
returns text
language plpgsql stable as $$
declare
    h        record;
    v_kural  smallint;
    v_cins   smallint;
    v_dogum  date;
    v_yas    integer;
begin
    if coalesce(p_hizmet_id, 0) = 0 or coalesce(p_taraf_id, 0) = 0 then return null; end if;

    select coalesce(x.cinsiyet, 0) as cinsiyet, x.yas_alt, x.yas_ust, x.ad
      into h from public.hizmet x where x.id = p_hizmet_id;
    if not found then return null; end if;
    v_kural := case h.cinsiyet when 3 then 1 when 4 then 2 else h.cinsiyet end;
    if v_kural = 0 and h.yas_alt is null and h.yas_ust is null then
        return null;                       -- kuralsız hizmet: herkese yapılır
    end if;

    select th.cinsiyet, th.dogum_tarihi into v_cins, v_dogum
      from public.taraf_hasta th where th.id = p_taraf_id;
    if not found then return null; end if;  -- hasta değil: kural aranmaz

    if v_kural <> 0 and coalesce(v_cins, 0) <> 0 and v_cins <> v_kural then
        return h.ad || ': yalnız ' || case v_kural when 1 then 'ERKEK' else 'KADIN' end || ' hastaya uygulanır.';
    end if;

    if v_dogum is not null then
        v_yas := extract(year from age(p_tarih, v_dogum))::integer;
        if h.yas_alt is not null and v_yas < h.yas_alt then
            return h.ad || ': ' || h.yas_alt || ' yaşından küçük hastaya uygulanmaz (hasta ' || v_yas || ' yaşında).';
        end if;
        if h.yas_ust is not null and v_yas > h.yas_ust then
            return h.ad || ': ' || h.yas_ust || ' yaşından büyük hastaya uygulanmaz (hasta ' || v_yas || ' yaşında).';
        end if;
    end if;
    return null;
end $$;

-- ---------------------------------------------------- belge satırı tetiği ---
-- Gerekçe YALNIZ istisnalı hizmette geçerli; kesin hizmette gerekçe yazılsa da reddedilir.
create or replace function public.tg_belge_satir_uygunluk()
returns trigger language plpgsql as $$
declare
    v_taraf    integer;
    v_tarih    date;
    v_sebep    text;
    v_istisna  boolean;
begin
    if new.hizmet_id is null then return new; end if;
    select coalesce(h.cinsiyet, 0) in (3, 4) into v_istisna from public.hizmet h where h.id = new.hizmet_id;
    if coalesce(new.uygunluk_notu, '') <> '' and coalesce(v_istisna, false) then return new; end if;

    select b.taraf_id, b.belge_tarihi::date into v_taraf, v_tarih
      from public.belge b where b.id = new.belge_id;
    if v_taraf is null then return new; end if;

    v_sebep := public.fn_hizmet_uygunluk(new.hizmet_id, v_taraf, coalesce(v_tarih, current_date));
    if v_sebep is not null then
        raise exception '%', v_sebep || case when coalesce(v_istisna, false) then ' (Gerekçe yazılarak eklenebilir.)'
                                             else ' Bu kural kesindir, gerekçeyle aşılamaz.' end
              using errcode = 'GK422';
    end if;
    return new;
end $$;

-- ------------------------------------------------------ radyoloji tetiği ---
create or replace function public.tg_radyoloji_istem_uygunluk()
returns trigger language plpgsql as $$
declare v_sebep text;
begin
    -- İSTİSNALI hizmet (ör. meme) hekim isteminde engellenmez - gerekçe ücret satırında istenir.
    if exists (select 1 from public.hizmet h where h.id = new.hizmet_id and coalesce(h.cinsiyet, 0) in (3, 4)) then
        return new;
    end if;
    v_sebep := public.fn_hizmet_uygunluk(new.hizmet_id, new.hasta_id, current_date);
    if v_sebep is not null then
        raise exception '%', v_sebep using errcode = 'GK422';
    end if;
    return new;
end $$;

-- ---------------------------------------------------------- lookup ---
-- Seçicide işaret: (E) / (K) kesin, (E?) / (K?) istisnalı.
create or replace view public.v_hizmet_lookup as
select h.id,
       case when h.kod = '' then h.ad else h.kod || ' - ' || h.ad end
         || case coalesce(h.cinsiyet, 0) when 1 then ' (E)' when 2 then ' (K)'
                                         when 3 then ' (E?)' when 4 then ' (K?)' else '' end
         || case when h.yas_alt is not null and h.yas_ust is not null
                      then ' [' || h.yas_alt || '-' || h.yas_ust || ' yas]'
                 when h.yas_alt is not null then ' [' || h.yas_alt || ' yas+]'
                 when h.yas_ust is not null then ' [' || h.yas_ust || ' yas ve alti]'
                 else '' end as ad,
       case when h.durum = 1 then 1 else 0 end::smallint as aktif,
       coalesce(h.cinsiyet, 0) as cinsiyet, h.yas_alt, h.yas_ust
  from public.hizmet h
 where coalesce(h.baslik_mi, 0) = 0;

do $$
declare v_k integer; v_i integer;
begin
  select count(*) filter (where cinsiyet in (1, 2)), count(*) filter (where cinsiyet in (3, 4))
    into v_k, v_i from public.hizmet;
  raise notice '1197: % hizmet kesin, % hizmet istisnalı cinsiyet kurallı.', v_k, v_i;
end $$;

commit;
