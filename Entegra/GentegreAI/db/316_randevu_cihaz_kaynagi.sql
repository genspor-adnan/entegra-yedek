-- 316: Randevuya CİHAZ kaynağı — radyoloji randevusu ayrı modül değil.
--
-- Kullanıcı: "standart randevu yapmıştık, bunun farkı var mı" → fark KAYNAK:
-- poliklinikte randevu HEKİME, radyolojide CİHAZA verilir. Motor (takvim,
-- durum akışı, çakışma, taşıma, hatırlatma) ortak kalsın diye yeni tablo/modül
-- açılmadı; randevuya cihaz alanı eklendi.
--
-- randevu.tip = 3 (Tetkik) zaten var - radyoloji randevusu bu tiptedir.

alter table public.randevu
  add column if not exists cihaz_id integer references public.radyoloji_cihaz(id);

comment on column public.randevu.cihaz_id is
  'Randevunun kaynağı CİHAZ ise (316) - radyolojide hekim yerine cihaz doludur.';

create index if not exists ix_randevu_cihaz
    on public.randevu (cihaz_id, baslangic) where cihaz_id is not null;

-- Hekim randevularının tarih araması da bu indeksten faydalansın.
create index if not exists ix_randevu_hekim_zaman
    on public.randevu (hekim_id, baslangic) where hekim_id is not null;

-- --------------------------------------------------------- cihaz lookup --
create or replace view public.v_radyoloji_cihaz_lookup as
select c.id,
       (c.ad || case when c.kod <> '' then ' · ' || c.kod else '' end)::varchar(160) as ad,
       case when coalesce(c.durum, 1) = 1 then 1 else 0 end as aktif
  from public.radyoloji_cihaz c;

comment on view public.v_radyoloji_cihaz_lookup is
  'Randevu kartındaki cihaz seçimi (316).';

-- ------------------------------------------------------ çakışma kuralı --
-- BUGÜNE KADAR ÇAKIŞMA KONTROLÜ YOKTU: aynı hekime/cihaza aynı saate iki
-- randevu yazılabiliyordu. Kural tetikte, çünkü randevu üç yoldan yazılıyor
-- (kart, takvim, radyoloji "Randevu Ver") - arayüze bırakılan kural atlanır.
--
--   * İptal (4) ve gelmedi (3) randevular yer tutmaz.
--   * Cihazda kapasite: radyoloji_cihaz.eszaman (aynı anda kaç hasta).
--   * Cihazın kapalı aralığı (bakım/arıza/tatil) randevuya kapalıdır.
--   * Mesai dışı ENGELLENMEZ: acil hasta bilerek mesai dışına yazılabilir;
--     takvim zaten o saatleri kapalı gösterir.
create or replace function public.tg_randevu_cakisma()
returns trigger language plpgsql as $$
declare
  v_bit   timestamp;
  v_adet  integer;
  v_kap   integer;
  v_ad    text;
begin
  -- KAYNAK ZORUNLULUGU: randevu ya hekime ya cihaza verilir.
  --   Kart alanlarindaki "zorunlu" bayragi ikisini birden zorunlu tutamaz
  --   (radyolojide hekim yok, poliklinikte cihaz yok) - kural burada.
  if new.cihaz_id is null and new.hekim_id is null then
    raise exception 'Randevu için hekim ya da cihaz seçilmeli.' using errcode = 'GK422';
  end if;
  if new.cihaz_id is null and coalesce(new.bolum, 0) = 0 then
    raise exception 'Poliklinik randevusunda bölüm seçilmeli.' using errcode = 'GK422';
  end if;

  if coalesce(new.durum, 1) in (3, 4) then return new; end if;

  v_bit := new.baslangic + make_interval(mins => greatest(coalesce(new.sure_dk, 0), 1));

  -- 1) CİHAZ kaynağı: kapasite kadar üst üste binebilir.
  if new.cihaz_id is not null then
    select coalesce(eszaman, 1) into v_kap
      from public.radyoloji_cihaz where id = new.cihaz_id;

    select count(*) into v_adet
      from public.randevu r
     where r.cihaz_id = new.cihaz_id
       and r.id is distinct from new.id
       and coalesce(r.durum, 1) not in (3, 4)
       and r.baslangic < v_bit
       and (r.baslangic + make_interval(mins => greatest(coalesce(r.sure_dk, 0), 1))) > new.baslangic;

    if v_adet >= coalesce(v_kap, 1) then
      raise exception 'Cihaz bu saatte dolu (aynı anda en fazla % hasta).', coalesce(v_kap, 1)
        using errcode = 'GK422';
    end if;

    -- 2) Cihazın kapalı aralığı (bakım / arıza / tatil).
    select coalesce(nullif(k.aciklama, ''),
                    (select d.ad from public.kod_deger d
                       join public.kod_liste l on l.id = d.liste_id
                      where l.kod = 'rad.kapatma' and d.deger = k.neden_tur))
      into v_ad
      from public.radyoloji_cihaz_kapatma k
     where k.cihaz_id = new.cihaz_id
       and k.baslangic < v_bit and k.bitis > new.baslangic
     limit 1;

    if v_ad is not null then
      raise exception 'Cihaz bu aralıkta randevuya kapalı: %', v_ad using errcode = 'GK422';
    end if;

  -- 3) HEKİM kaynağı: aynı hekime çakışan randevu olamaz.
  elsif new.hekim_id is not null then
    select count(*) into v_adet
      from public.randevu r
     where r.hekim_id = new.hekim_id
       and r.cihaz_id is null
       and r.id is distinct from new.id
       and coalesce(r.durum, 1) not in (3, 4)
       and r.baslangic < v_bit
       and (r.baslangic + make_interval(mins => greatest(coalesce(r.sure_dk, 0), 1))) > new.baslangic;

    if v_adet > 0 then
      raise exception 'Hekimin bu saatte başka randevusu var.' using errcode = 'GK422';
    end if;
  end if;

  return new;
end $$;

drop trigger if exists tr_randevu_cakisma on public.randevu;
create trigger tr_randevu_cakisma
  before insert or update on public.randevu
  for each row execute function public.tg_randevu_cakisma();

comment on function public.tg_randevu_cakisma() is
  'Randevu çakışma kuralı (316): cihazda kapasite + kapatma, hekimde tekillik.';
