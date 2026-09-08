-- =====================================================================
-- 482 - HİZMETTE CİNSİYET VE YAŞ UYGUNLUĞU
--
-- Kullanıcı: "bazı hizmetler bazı cinsiyetlere yapılamaz - doğum erkek için
-- olmaz ve 15 yaşından aşağı da olmaz; prostat sadece erkeklere ve 20 yaşından
-- sonra olur; çok hizmet de her iki cinsiyet için olur. Yanlış cinsiyete
-- hizmet eklemeyi önlemek gerekiyor."
--
-- KURAL HİZMET KARTINDA durur, ekranda değil: aynı kısıt ücret satırında,
-- laboratuvar isteminde, radyoloji isteminde ve pakette geçerlidir. Ekrana
-- yazılan bir kural, dördüncü ekranda unutulur.
--
--   cinsiyet : 0 farketmez · 1 yalnız erkek · 2 yalnız kadın
--   yas_alt  : bu yaştan KÜÇÜĞE yapılamaz (yıl, null = sınır yok)
--   yas_ust  : bu yaştan BÜYÜĞE yapılamaz (yıl, null = sınır yok)
--
-- SERT RED DEĞİL, GEREKÇELİ GEÇİŞ: kuralın gerçek istisnaları var (erkekte
-- meme kanseri taraması, yaşı belirsiz kimliksiz hasta). Satırda
-- `uygunluk_notu` doluysa tetik geçirir ve not kayıtta kalır - kim, neden
-- zorladı sorusu cevapsız kalmasın. Notu yazma yetkisi API tarafındadır.
-- =====================================================================

alter table public.hizmet
  add column if not exists cinsiyet smallint not null default 0,
  add column if not exists yas_alt  smallint,
  add column if not exists yas_ust  smallint;

comment on column public.hizmet.cinsiyet is
  'Hizmetin cinsiyet kısıtı (482): 0 farketmez · 1 yalnız erkek · 2 yalnız kadın.';
comment on column public.hizmet.yas_alt is
  'Bu yaştan küçüğe yapılamaz (482, yıl). Boş = alt sınır yok.';
comment on column public.hizmet.yas_ust is
  'Bu yaştan büyüğe yapılamaz (482, yıl). Boş = üst sınır yok.';

alter table public.hizmet
  drop constraint if exists ck_hizmet_yas_araligi;
alter table public.hizmet
  add constraint ck_hizmet_yas_araligi
  check (yas_alt is null or yas_ust is null or yas_alt <= yas_ust) not valid;

alter table public.belge_satir
  add column if not exists uygunluk_notu varchar(200) not null default '';
comment on column public.belge_satir.uygunluk_notu is
  'Cinsiyet/yaş kuralı GEREKÇEYLE aşıldıysa sebebi (482). Boşsa kural uygulanmıştır.';

-- ------------------------------------------------------------- kural ---
-- Tek yerde: hizmet kuralı + hastanın cinsiyet/yaşı → uymuyorsa SEBEP metni,
--   uyuyorsa null. Ekran da, tetik de, API de bunu çağırır.
create or replace function public.fn_hizmet_uygunluk(
    p_hizmet_id integer,
    p_taraf_id  integer,
    p_tarih     date default current_date)
returns text
language plpgsql stable as $$
declare
    h        record;
    v_cins   smallint;
    v_dogum  date;
    v_yas    integer;
begin
    if coalesce(p_hizmet_id, 0) = 0 or coalesce(p_taraf_id, 0) = 0 then return null; end if;

    select coalesce(x.cinsiyet, 0) as cinsiyet, x.yas_alt, x.yas_ust, x.ad
      into h from public.hizmet x where x.id = p_hizmet_id;
    if not found then return null; end if;
    if coalesce(h.cinsiyet, 0) = 0 and h.yas_alt is null and h.yas_ust is null then
        return null;                       -- kuralsız hizmet: herkese yapılır
    end if;

    select th.cinsiyet, th.dogum_tarihi into v_cins, v_dogum
      from public.taraf_hasta th where th.id = p_taraf_id;
    -- HASTA DEĞİL (kurum/tedarikçi faturası): kural aranmaz.
    if not found then return null; end if;

    if coalesce(h.cinsiyet, 0) <> 0 and coalesce(v_cins, 0) <> 0
       and v_cins <> h.cinsiyet then
        return h.ad || ': yalnız '
             || case h.cinsiyet when 1 then 'ERKEK' else 'KADIN' end
             || ' hastaya uygulanır.';
    end if;

    if v_dogum is not null then
        v_yas := extract(year from age(p_tarih, v_dogum))::integer;
        if h.yas_alt is not null and v_yas < h.yas_alt then
            return h.ad || ': ' || h.yas_alt || ' yaşından küçük hastaya uygulanmaz (hasta '
                 || v_yas || ' yaşında).';
        end if;
        if h.yas_ust is not null and v_yas > h.yas_ust then
            return h.ad || ': ' || h.yas_ust || ' yaşından büyük hastaya uygulanmaz (hasta '
                 || v_yas || ' yaşında).';
        end if;
    end if;

    return null;
end $$;

comment on function public.fn_hizmet_uygunluk(integer, integer, date) is
  'Hizmetin hastaya uygunluğu (482): uymuyorsa sebep metni, uyuyorsa null.';

-- --------------------------------------------------------- belge tetiği ---
create or replace function public.tg_belge_satir_uygunluk()
returns trigger language plpgsql as $$
declare
    v_taraf  integer;
    v_tarih  date;
    v_sebep  text;
begin
    if new.hizmet_id is null then return new; end if;
    -- Gerekçe yazılmışsa kural bilerek aşılmıştır: not kayıtta kalır.
    if coalesce(new.uygunluk_notu, '') <> '' then return new; end if;

    select b.taraf_id, b.belge_tarihi::date into v_taraf, v_tarih
      from public.belge b where b.id = new.belge_id;
    if v_taraf is null then return new; end if;

    v_sebep := public.fn_hizmet_uygunluk(new.hizmet_id, v_taraf,
                                         coalesce(v_tarih, current_date));
    if v_sebep is not null then
        raise exception '%', v_sebep using errcode = 'GK422';
    end if;
    return new;
end $$;

drop trigger if exists tg_belge_satir_uygunluk on public.belge_satir;
create trigger tg_belge_satir_uygunluk
    before insert or update of hizmet_id, uygunluk_notu on public.belge_satir
    for each row execute function public.tg_belge_satir_uygunluk();

-- ------------------------------------------------------ radyoloji tetiği ---
-- Radyoloji istemi ücret satırından bağımsız da açılabiliyor (hekim istemi):
--   aynı kapı orada da dursun.
create or replace function public.tg_radyoloji_istem_uygunluk()
returns trigger language plpgsql as $$
declare v_sebep text;
begin
    v_sebep := public.fn_hizmet_uygunluk(new.hizmet_id, new.hasta_id, current_date);
    if v_sebep is not null then
        raise exception '%', v_sebep using errcode = 'GK422';
    end if;
    return new;
end $$;

drop trigger if exists tg_radyoloji_istem_uygunluk on public.radyoloji_istem;
create trigger tg_radyoloji_istem_uygunluk
    before insert or update of hizmet_id, hasta_id on public.radyoloji_istem
    for each row execute function public.tg_radyoloji_istem_uygunluk();

-- ---------------------------------------------------------- lookup ---
-- Hizmet seçicisi kuralı ÖNCEDEN göstersin: yanlış satır hiç eklenmesin.
-- Kolon tipi degistigi icin view YENIDEN kurulur (PG replace ile tip
--   degistirmeye izin vermez).
drop view if exists public.v_hizmet_lookup;
create view public.v_hizmet_lookup as
select h.id,
       case when h.kod = '' then h.ad else h.kod || ' - ' || h.ad end
         || case when coalesce(h.cinsiyet, 0) = 1 then ' (E)'
                 when coalesce(h.cinsiyet, 0) = 2 then ' (K)' else '' end
         || case when h.yas_alt is not null and h.yas_ust is not null
                      then ' [' || h.yas_alt || '-' || h.yas_ust || ' yas]'
                 when h.yas_alt is not null then ' [' || h.yas_alt || ' yas+]'
                 when h.yas_ust is not null then ' [' || h.yas_ust || ' yas ve alti]'
                 else '' end as ad,
       case when h.durum = 1 then 1 else 0 end::smallint as aktif,
       coalesce(h.cinsiyet, 0) as cinsiyet, h.yas_alt, h.yas_ust
  from public.hizmet h
 where coalesce(h.baslik_mi, 0) = 0;

comment on view public.v_hizmet_lookup is
  'Hizmet seçici (482): ad yanında cinsiyet/yaş kısıtı görünür - yanlış seçim baştan engellensin.';

do $$
begin
    raise notice '482 tamam: hizmet cinsiyet/yas kurali + belge ve radyoloji tetikleri';
end $$;
