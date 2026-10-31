\set ON_ERROR_STOP on
-- ============================================================================
--  1203 — Hizmet uygunluğu: istisnalı cinsiyette YAŞ kuralı korunur
--
--  Kod inceleme 30.10.2026 K44 (1197'nin hatası): istisnalı cinsiyet (3/4)
--  kuralı gerekçeyle aşılırken tetikler fn_hizmet_uygunluk'u hiç çağırmıyor,
--  yaş_alt / yaş_üst denetimi de atlanıyordu. Meme tetkikinde (4) gerekçe
--  yazılan erkek hastada yaş sınırı denetlenmiyordu.
--
--  Çözüm: fn_hizmet_uygunluk'a p_cinsiyet_atla parametresi (varsayılan false,
--  eski çağrılar aynen çalışır). Tetikler istisna + gerekçe yolunda fonksiyonu
--  cinsiyeti atlayarak çağırır - yaş kuralı yine uygulanır.
-- ============================================================================
begin;

drop function if exists public.fn_hizmet_uygunluk(integer, integer, date);

create or replace function public.fn_hizmet_uygunluk(
    p_hizmet_id      integer,
    p_taraf_id       integer,
    p_tarih          date default current_date,
    p_cinsiyet_atla  boolean default false)
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
    -- 3 = istisnalı erkek, 4 = istisnalı kadın: kural yönü 1/2 ile aynı; istisna ayrımı tetiklerde.
    v_kural := case h.cinsiyet when 3 then 1 when 4 then 2 else h.cinsiyet end;
    if p_cinsiyet_atla then v_kural := 0; end if;           -- 1203: gerekçeli istisna yolu
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

comment on function public.fn_hizmet_uygunluk(integer, integer, date, boolean) is
  '1197/1203: hizmetin cinsiyet (1/2 kesin, 3/4 istisnalı) ve yaş kuralı; p_cinsiyet_atla = gerekçeli istisna yolunda yalnız yaş denetlenir.';

-- ---------------------------------------------------- belge satırı tetiği ---
-- Gerekçe YALNIZ istisnalı hizmette cinsiyet kuralını aşar; yaş kuralı her durumda uygulanır (1203).
create or replace function public.tg_belge_satir_uygunluk()
returns trigger language plpgsql as $$
declare
    v_taraf    integer;
    v_tarih    date;
    v_sebep    text;
    v_istisna  boolean;
    v_atla     boolean;
begin
    if new.hizmet_id is null then return new; end if;
    select coalesce(h.cinsiyet, 0) in (3, 4) into v_istisna from public.hizmet h where h.id = new.hizmet_id;
    v_atla := coalesce(new.uygunluk_notu, '') <> '' and coalesce(v_istisna, false);

    select b.taraf_id, b.belge_tarihi::date into v_taraf, v_tarih
      from public.belge b where b.id = new.belge_id;
    if v_taraf is null then return new; end if;

    v_sebep := public.fn_hizmet_uygunluk(new.hizmet_id, v_taraf, coalesce(v_tarih, current_date), v_atla);
    if v_sebep is not null then
        raise exception '%', v_sebep || case when coalesce(v_istisna, false) and not v_atla then ' (Gerekçe yazılarak eklenebilir.)'
                                             when v_atla then ''
                                             else ' Bu kural kesindir, gerekçeyle aşılamaz.' end
              using errcode = 'GK422';
    end if;
    return new;
end $$;

-- ------------------------------------------------------ radyoloji tetiği ---
create or replace function public.tg_radyoloji_istem_uygunluk()
returns trigger language plpgsql as $$
declare
    v_sebep    text;
    v_istisna  boolean;
begin
    -- İSTİSNALI hizmet (ör. meme) hekim isteminde cinsiyetle engellenmez - gerekçe ücret satırında istenir;
    --   yaş kuralı yine denetlenir (1203).
    select coalesce(h.cinsiyet, 0) in (3, 4) into v_istisna from public.hizmet h where h.id = new.hizmet_id;
    v_sebep := public.fn_hizmet_uygunluk(new.hizmet_id, new.hasta_id, current_date, coalesce(v_istisna, false));
    if v_sebep is not null then
        raise exception '%', v_sebep using errcode = 'GK422';
    end if;
    return new;
end $$;

commit;
