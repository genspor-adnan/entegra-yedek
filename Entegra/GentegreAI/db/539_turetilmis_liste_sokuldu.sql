-- =====================================================================
--  539_turetilmis_liste_sokuldu.sql
--  TÜRETİLMİŞ FİYAT LİSTESİ mekanizması kaldırıldı.
--
--  Kullanıcı: "kullanılmayan alanları hep kaldır, gerekirse ileride
--  ekleriz" → liste başlığındaki `taban_liste_id`, `carpan`, `yuvarlama`,
--  `yuvarlama_birim`, `katki_tutar`, `ek_katki_tipi`, `ek_katki_deger` ve
--  satırdaki karşılıkları düşürülüyor.
--
--  NEDEN GÜVENLİ: bu kurulumda hiçbir liste bir başkasından TÜRETİLMİYOR -
--  28.328 satırın hiçbirinde taban liste/yuvarlama dolu değil. Üç tarife de
--  kendi kaynağından besleniyor: SUT fiyatı SKRS ambarından (535), TTB
--  katsayı × çarpan (533), Özel üretim fonksiyonuyla (536/538). "A
--  listesinden %20 zamlı B listesi" kurgusu kullanılmıyordu.
--
--  NE KALIYOR: satırdaki `taban_fiyat` (TTB KATSAYISI) ve `carpan` DURUYOR -
--  ikisi TTB tarifesinin çekirdeği. Satırdaki `katki_tutar` da duruyor
--  (hastadan alınacak tutar, elle girilir); kalkan yalnız LİSTE
--  VARSAYILANIDIR.
--
--  BEDELİ: türetilmiş liste ileride gerekirse kolon + fonksiyon + kart
--  birlikte geri gelmeli. Bu göç o özelliği tümüyle söküyor.
-- =====================================================================

-- ------------------------------------------------------------- yedek ----
create table if not exists public._yedek_fiyat_liste_kural_539 as
select id, taban_liste_id, carpan, yuvarlama, yuvarlama_birim,
       katki_tutar, ek_katki_tipi, ek_katki_deger
  from public.fiyat_listesi;

create table if not exists public._yedek_fiyat_satir_kural_539 as
select id, liste_id, taban_liste_id, taban_satir_id, yuvarlama, yuvarlama_birim,
       ek_katki_tipi, ek_katki_deger, uretim_tarihi
  from public.fiyat_listesi_satir;

-- --------------------------------------------------- 1) fiyat cozumu ----
/**
 * Listenin bir kalemdeki fiyatı: YALNIZ LİSTEDE YAZILI SATIR.
 *
 * Taban liste zinciri (özyineleme, çarpan, yuvarlama) kaldırıldı; imza
 * korunuyor çünkü `fn_belge_kalem_fiyati`, `fn_fiyat_listesi_uret` ve
 * `fn_sls_carpan_manuel` bu fonksiyonu çağırıyor. `p_derinlik` ve `p_ezme`
 * artık YOK SAYILIR - çağıran yerleri tek tek değiştirmek yerine imza
 * sabit kaldı.
 *
 * Satır yoksa fiyat da yoktur: kalem kartından (stok_fiyat/hizmet_fiyat)
 * devralma da kalktı - fiyat listesi artık tek kaynaktır, "listede olmayan
 * kalemin fiyatı nereden geldi" sorusu doğmaz.
 */
create or replace function public.fn_fiyat_listesi_fiyat(
    p_liste_id integer,
    p_stok_id integer default null,
    p_hizmet_id integer default null,
    p_derinlik integer default 0,
    p_yazili boolean default true,
    p_ezme boolean default true)
returns table (fiyat numeric, doviz_cinsi varchar, kdv_dahil smallint,
               kaynak text, taban numeric, carpan_kullanilan numeric,
               kaynak_satir_id integer)
language plpgsql stable as $$
declare
    l public.fiyat_listesi%rowtype;
    r public.fiyat_listesi_satir%rowtype;
begin
    select * into l from public.fiyat_listesi where id = p_liste_id;
    if not found then return; end if;

    select * into r from public.fiyat_listesi_satir
     where liste_id = p_liste_id
       and (not p_yazili or durum = 1)
       and (p_stok_id   is not null and stok_id   = p_stok_id
         or p_hizmet_id is not null and hizmet_id = p_hizmet_id)
     limit 1;
    if not found then return; end if;
    if p_yazili and not (r.yazim in (1, 3) or coalesce(r.fiyat, 0) > 0) then
        return;
    end if;

    -- KDV DAHIL/HARIC LISTENIN OZELLIGI (495): satirin kendi kolonu okunmaz.
    return query select r.fiyat, r.doviz_cinsi, l.kdv_dahil,
                        case r.yazim when 1 then 'satir-manuel'
                                     when 3 then 'satir-import'
                                     else 'satir-hesap' end,
                        nullif(r.taban_fiyat, 0), r.carpan, r.id;
end $$;

comment on function public.fn_fiyat_listesi_fiyat(integer, integer, integer, integer, boolean, boolean) is
    'Listenin kalemdeki fiyatı - yalnız yazılı satır; taban liste zinciri 539''da kaldırıldı.';

-- ------------------------------------------- 2) katilim payi (SGK) ----
/** Satırın katılım payı. Liste varsayılanı ve taban liste devri kalktı (539). */
create or replace function public.fn_fiyat_listesi_katki(
    p_liste_id integer, p_stok_id integer default null,
    p_hizmet_id integer default null, p_derinlik integer default 0)
returns numeric language plpgsql stable as $$
declare v_katki numeric;
begin
    if p_liste_id is null then return 0; end if;
    select s.katki_tutar into v_katki
      from public.fiyat_listesi_satir s
     where s.liste_id = p_liste_id and s.durum = 1
       and (p_stok_id   is not null and s.stok_id   = p_stok_id
         or p_hizmet_id is not null and s.hizmet_id = p_hizmet_id)
     limit 1;
    return coalesce(v_katki, 0);
end $$;

-- ---------------------------------------------------- 3) ek katki ----
-- EK KATKI TÜMÜYLE KALKTI (532'de karttan, burada şemadan): hastane farkı
--   fiyat listesinde tutulmuyordu (hiçbir satırda dolu değildi) ve dağılım
--   zinciri onu 0 olarak alacak.
create or replace function public.fn_fiyat_listesi_ek_katki(
    p_liste_id integer, p_stok_id integer default null,
    p_hizmet_id integer default null, p_taban numeric default 0,
    p_derinlik integer default 0)
returns numeric language sql immutable as $$
    -- Fonksiyon imzası KORUNUYOR: `fn_belge_satir_dagilim_hesapla` çağırıyor.
    --   Ek katkı artık fiyat listesinde tanımlanmıyor - her zaman 0.
    select 0::numeric;
$$;

comment on function public.fn_fiyat_listesi_ek_katki(integer, integer, integer, numeric, integer) is
    'Ek katkı fiyat listesinden kaldırıldı (539) - imza uyumluluğu için 0 döner.';

-- --------------------------------------- 4) satir tetigi (carpan) ----
/**
 * Satır tetiği: çarpan/fiyat ilişkisi. Taban liste zinciri ve liste
 * yuvarlaması kalktı - yuvarlama iki hane (539).
 */
create or replace function public.fn_sls_carpan_manuel() returns trigger
language plpgsql as $$
begin
    -- CARPAN degisti: Manuel + fiyat = katsayi x carpan.
    if new.carpan is distinct from old.carpan then
        new.yazim := 1;
        if new.carpan is not null and new.carpan > 0
           and coalesce(new.taban_fiyat, 0) > 0 then
            new.fiyat := round(new.taban_fiyat * new.carpan, 2);
        end if;
        return new;
    end if;

    -- FIYAT elle degisti: Manuel; katsayi varsa carpan geri hesaplanir.
    if new.fiyat is distinct from old.fiyat then
        new.yazim := 1;
        if coalesce(new.taban_fiyat, 0) > 0 and coalesce(new.fiyat, 0) > 0 then
            new.carpan := round(new.fiyat / new.taban_fiyat, 6);
        end if;
    end if;
    return new;
end $$;

-- ------------------------------------------- 5) tarife tetigi (533) ----
create or replace function public.tg_fiyat_satir_tarife() returns trigger
language plpgsql as $$
declare
    v_tip     smallint;
    v_yukleme boolean := coalesce(current_setting('gentegre.sut_yukleme', true), '') = '1';
begin
    select tarife_tipi into v_tip from public.fiyat_listesi where id = new.liste_id;
    v_tip := coalesce(v_tip, 0);

    -- TTB/HUV: fiyat TURETILMIS deger - katsayi x carpan (533).
    if v_tip = 2 then
        if coalesce(new.taban_fiyat, 0) > 0 and coalesce(new.carpan, 0) > 0 then
            new.fiyat := round(new.taban_fiyat * new.carpan, 2);
        elsif tg_op = 'UPDATE' and new.fiyat is distinct from old.fiyat then
            new.fiyat := old.fiyat;
        end if;
    end if;

    -- SUT: fiyat SKRS'den gelir; yukleyici disinda degistirilemez (518).
    if v_tip = 3 and tg_op = 'UPDATE'
       and new.fiyat is distinct from old.fiyat
       and not v_yukleme then
        raise exception 'SUT fiyatı elle değiştirilemez - SKRS/SUT aktarımından gelir.'
              using errcode = 'GK422';
    end if;

    return new;
end $$;

-- --------------------------------------- 6) taban liste tetikleri ----
-- Taban liste kalmayınca döngü ve yön kontrolünün konusu da kalmadı.
drop trigger if exists trg_fiyat_listesi_dongu on public.fiyat_listesi;
drop trigger if exists trg_fiyat_listesi_yon on public.fiyat_listesi;
drop function if exists public.fn_fiyat_listesi_dongu_kontrol();
drop function if exists public.fn_fiyat_listesi_yon_kontrol();

-- ------------------------------------------- 7) liste uretimi (209) ----
/**
 * "Listeyi Üret": katalogdaki kalemleri listeye satır olarak ekler.
 * Taban liste zinciri kalktı (539) - satır fiyatı listenin KENDİ yazılı
 * satırından okunur; henüz fiyatı olmayan kalem FİYATSIZ sayılır ve
 * atlanmaz, 0 ile eklenir: liste önce KALEM listesi olarak kurulur, fiyat
 * sonra (SKRS aktarımı / katsayı yükleme / türetme fonksiyonu) doldurulur.
 */
create or replace function public.fn_fiyat_listesi_uret(
    p_liste_id integer, p_kullanici integer default 0,
    p_stok boolean default true, p_hizmet boolean default true)
returns table (eklenen integer, guncellenen integer, korunan integer, fiyatsiz integer)
language plpgsql as $$
declare
    v_ekle     integer := 0;
    v_guncelle integer := 0;
    v_koru     integer := 0;
    v_yok      integer := 0;
    k          record;
    v_f        record;
begin
    perform 1 from public.fiyat_listesi where id = p_liste_id;
    if not found then
        raise exception 'Fiyat listesi bulunamadi: %', p_liste_id;
    end if;

    select count(*) into v_koru from public.fiyat_listesi_satir
     where liste_id = p_liste_id and yazim in (1, 3);

    for k in
        select s.id as stok_id, null::integer as hizmet_id, s.ana_birim as birim
          from public.stok s
         where p_stok and s.durum = 1
        union all
        select null, h.id, h.birim
          from public.hizmet h
         where p_hizmet and h.durum = 1 and coalesce(h.baslik_mi, 0) = 0
    loop
        select * into v_f
          from public.fn_fiyat_listesi_fiyat(p_liste_id, k.stok_id, k.hizmet_id, 0, false);

        insert into public.fiyat_listesi_satir
            (liste_id, stok_id, hizmet_id, fiyat, doviz_cinsi, kdv_dahil, birim,
             durum, yazim, ekleyen, degistiren)
        values
            (p_liste_id, k.stok_id, k.hizmet_id, coalesce(v_f.fiyat, 0),
             coalesce(v_f.doviz_cinsi, 'TL'), coalesce(v_f.kdv_dahil, 0),
             coalesce(k.birim, 0), 1, 2, p_kullanici, p_kullanici)
        on conflict do nothing;

        if found then
            v_ekle := v_ekle + 1;
            if coalesce(v_f.fiyat, 0) <= 0 then v_yok := v_yok + 1; end if;
        end if;
    end loop;

    return query select v_ekle, v_guncelle, v_koru, v_yok;
end $$;

-- ------------------------------------------------- 8) gorunumler ----
-- Iki gorunum taban liste/yuvarlama kolonlarini okuyordu; kolon dusmeden
--   once dogru surumleri kurulur.
drop view if exists public.v_fiyat_listesi_satir;
create view public.v_fiyat_listesi_satir as
select r.id,
       r.liste_id,
       l.ad as liste_adi,
       case when r.stok_id is not null then 1 else 2 end as kalem_turu,
       coalesce(s.kod, h.kod, ''::varchar) as kod,
       coalesce(s.ad, h.ad, ''::varchar) as ad,
       coalesce(ks.ad, kh.ad, ''::varchar) as kategori,
       r.stok_id,
       r.hizmet_id,
       r.fiyat,
       r.doviz_cinsi,
       l.kdv_dahil,
       r.birim,
       r.durum,
       r.yazim,
       r.carpan,
       r.taban_fiyat,
       r.katki_tutar,
       l.sube_id
  from public.fiyat_listesi_satir r
  join public.fiyat_listesi l on l.id = r.liste_id
  left join public.stok s on s.id = r.stok_id
  left join public.hizmet h on h.id = r.hizmet_id
  left join public.kategori ks on ks.id = s.kategori
  left join public.kategori kh on kh.id = h.kategori;

drop view if exists public.v_fiyat_listesi_kullanim;
create view public.v_fiyat_listesi_kullanim as
select l.id as liste_id, l.ad,
       (select count(*) from public.taraf t
         where t.satis_fiyat_listesi_id = l.id or t.alis_fiyat_listesi_id = l.id)
         as cari_sayisi,
       0::bigint as turetilen_liste
  from public.fiyat_listesi l;

-- ----------------------------------------------- 8) kolonlar duser ----
alter table public.fiyat_listesi
    drop column if exists taban_liste_id,
    drop column if exists carpan,
    drop column if exists yuvarlama,
    drop column if exists yuvarlama_birim,
    drop column if exists katki_tutar,
    drop column if exists ek_katki_tipi,
    drop column if exists ek_katki_deger;

alter table public.fiyat_listesi_satir
    drop column if exists taban_liste_id,
    drop column if exists taban_satir_id,
    drop column if exists yuvarlama,
    drop column if exists yuvarlama_birim,
    drop column if exists ek_katki_tipi,
    drop column if exists ek_katki_deger,
    drop column if exists uretim_tarihi;

-- Karşılıksız kalan kod listeleri de gider.
delete from public.kod_deger
 where liste_id in (select id from public.kod_liste
                     where kod in ('fiyat_listesi.yuvarlama', 'fiyat_listesi.ek_katki_tipi'));
delete from public.kod_liste
 where kod in ('fiyat_listesi.yuvarlama', 'fiyat_listesi.ek_katki_tipi');

do $$
declare v_kalan integer;
begin
    select count(*) into v_kalan from information_schema.columns
     where table_schema = 'public'
       and table_name in ('fiyat_listesi', 'fiyat_listesi_satir')
       and column_name in ('taban_liste_id', 'taban_satir_id', 'yuvarlama',
                           'yuvarlama_birim', 'ek_katki_tipi', 'ek_katki_deger',
                           'uretim_tarihi')
       or (table_schema = 'public' and table_name = 'fiyat_listesi'
           and column_name in ('carpan', 'katki_tutar'));
    raise notice '539 tamam: turetilmis liste sokuldu, kalan kolon %.', v_kalan;
end $$;
