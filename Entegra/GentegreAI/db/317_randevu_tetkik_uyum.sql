-- 317: Randevuda TETKİK-CİHAZ uyumu + randevudan kabul akışının izi.
--
-- Kullanıcı akışı: hasta çoğunlukla kuruma GELMEDEN randevu alır (telefon).
-- O anda istem/başvuru/ödeme yoktur - yalnız randevu vardır. Hasta gelince
-- "Geldi" denir, başvuru + istem orada doğar ve cihazın çalışma listesine
-- (MWL) o an düşer.
--
-- Bu, randevu kartındaki tetkik seçimini kritik yapar: yanlış cihaza yazılan
-- randevu ancak hasta geldiğinde fark edilir. İstem tarafında modalite uyumu
-- zaten var (RadyolojiUclari); aynı kural randevu için de gerekli - randevu
-- üç yoldan yazılıyor (kart, takvim, radyoloji "Randevu Ver").

-- --------------------------------------------------- tetkik-cihaz uyumu --
create or replace function public.tg_randevu_cakisma()
returns trigger language plpgsql as $$
declare
  v_bit       timestamp;
  v_adet      integer;
  v_kap       integer;
  v_ad        text;
  v_cihaz_mod smallint;
  v_cihaz_ad  text;
  v_hiz_mod   smallint;
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

  -- TETKİK-CİHAZ UYUMU (317): MR tetkiki Röntgen cihazına randevulanamaz.
  --   Hastanın boşuna gelmesi ve randevunun taşınması demek olurdu.
  if new.cihaz_id is not null and new.hizmet_id is not null then
    select coalesce(c.modalite, 0), c.ad into v_cihaz_mod, v_cihaz_ad
      from public.radyoloji_cihaz c where c.id = new.cihaz_id;
    select coalesce(h.modalite, 0) into v_hiz_mod
      from public.hizmet h where h.id = new.hizmet_id;

    -- Modalitesi olmayan hizmet (poliklinik işlemi) cihaza yazılabilir:
    --   kural yalnız İKİ TARAF DA radyolojiyse işler.
    if coalesce(v_hiz_mod, 0) > 0 and coalesce(v_cihaz_mod, 0) > 0
       and v_hiz_mod <> v_cihaz_mod then
      raise exception 'Tetkik ile cihazın modalitesi uyuşmuyor - tetkik: %, cihaz: % (%).',
        coalesce((select d.ad from public.kod_deger d
                    join public.kod_liste l on l.id = d.liste_id
                   where l.kod = 'rad.modalite' and d.deger = v_hiz_mod), v_hiz_mod::text),
        v_cihaz_ad,
        coalesce((select d.ad from public.kod_deger d
                    join public.kod_liste l on l.id = d.liste_id
                   where l.kod = 'rad.modalite' and d.deger = v_cihaz_mod), v_cihaz_mod::text)
        using errcode = 'GK422';
    end if;
  end if;

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

comment on function public.tg_randevu_cakisma() is
  'Randevu kuralları (316/317): kaynak zorunluluğu, tetkik-cihaz modalite uyumu, '
  'cihazda kapasite + kapatma, hekimde tekillik.';

-- ----------------------------------------- randevunun protokol süresi ----
-- Randevu kartı ve takvim, tetkik seçilince süreyi buradan doldurur: MR 30 dk,
-- röntgen 10 dk - kart varsayılanı 15 dk her ikisi için de yanlış.
create or replace view public.v_randevu_tetkik_sure as
select h.id            as hizmet_id,
       h.ad            as hizmet_adi,
       coalesce(h.modalite, 0)                as modalite,
       coalesce(nullif(p.sure_dk, 0), 0)      as protokol_sure,
       coalesce(p.kontrast, 0)                as kontrast,
       coalesce(p.hazirlik_metni, '')         as hazirlik_metni
  from public.hizmet h
  left join public.radyoloji_protokol p on p.hizmet_id = h.id
 where coalesce(h.modalite, 0) > 0;

comment on view public.v_randevu_tetkik_sure is
  'Randevu kartında tetkik seçilince süre/hazırlık ön dolumu (317).';
