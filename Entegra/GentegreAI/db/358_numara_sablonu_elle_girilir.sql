-- ============================================================================
--  358 - NUMARALANDIRMA: "elle girilir" bayragi + KAYIT KABUL numaralari
--
--  Kullanici: "satış / alış numaralandırma tablosu yapmıştın.. dosyano/
--  protokolno ayarları da onun içinde tutulabilir".
--
--  Boylece numara ile ilgili HER SEY tek tabloda (numara_sablonu): on ek, hane,
--  baslangic, yururluk tarihi, sube - ve artik "numarayi sistem mi verecek
--  yoksa kullanici mi yazacak" karari da.
--
--  356'da referansa yazilan `hasta.dosya_no_otomatik` /
--  `basvuru.protokol_no_otomatik` ayarlari KALDIRILIR; yerine
--  numara_sablonu.elle_girilir gecer (0 = sistem uretir, 1 = elle yazilir).
--
--  Hasta dosya numarasi belge degildir; kendi tur kodu 900 ile ayni tabloda
--  durur. Tur adlari icin kasa_islem_turu'na satir EKLENMEZ (o tablo kasa/belge
--  turleri katalogu) - kayit kabul numaralari kendi gorunumunden okunur.
-- ============================================================================

alter table public.numara_sablonu
  add column if not exists elle_girilir smallint not null default 0;

comment on column public.numara_sablonu.elle_girilir is
  'Numarayi kim verir (358): 0 = sistem uretir (on ek + hane + sayac), '
  '1 = kullanici elle yazar. Elle modda bos birakilirsa yine sistem uretir - '
  'kayit numarasiz kalmaz (hasta dosya no bunun DISINDA: elle modda zorunludur).';

-- KAYIT KABUL numara turleri: 900 hasta dosya no + 19 basvuru protokol no.
--   `aktif` kolonu diger v_numara_turu_* gorunumleriyle ayni sozlesme icin var.
create or replace view public.v_numara_turu_kimlik as
select 900 as id, 'Hasta Dosya No'::varchar as ad, 1::smallint as aktif
union all
select 19  as id, 'Başvuru Protokol No'::varchar as ad, 1::smallint as aktif;

comment on view public.v_numara_turu_kimlik is
  'Kayit kabul numaralari (358): 900 hasta dosya no, 19 basvuru protokol no.';

-- Hasta dosya no sablonu: VARSAYILAN ELLE (mevcut davranis korunur).
insert into public.numara_sablonu (tur, baslama_tarihi, on_ek, baslama_no,
                                   sube_id, durum, elle_girilir, aciklama)
select 900, current_date, '', '00000001', 0, 1, 1,
       'Hasta dosya numarasi (358)'
 where not exists (select 1 from public.numara_sablonu where tur = 900);

-- ================================================== hasta dosya no uretimi ==
-- 356'daki sequence yerine ORTAK sayac (fn_numara_sirada): on ek ve hane
-- sablondan gelir, sayac sablona baglidir - on ek degisince yeni sayac baslar.
create or replace function public.fn_hasta_dosya_no(p_sube_id integer default 0)
returns character varying
language plpgsql
as $$
declare
    v_sablon public.numara_sablonu;
begin
    v_sablon := public.fn_numara_sablonu_bul(900, p_sube_id, current_date);
    if v_sablon.id is null then
        -- Sablon yoksa 8 hane, 1'den: hicbir ayar yapilmamis kurulumda da calisir.
        return public.fn_numara_sirada('taraf.kod|HASTA', 'taraf', 'kod',
                                       'hasta dosya no', 8, 1);
    end if;
    return v_sablon.on_ek || public.fn_numara_sirada(
               'taraf.kod|HASTA|N' || v_sablon.id::text, 'taraf', 'kod',
               'hasta dosya no / sablon ' || v_sablon.id::text,
               v_sablon.hane, v_sablon.baslangic);
end $$;

comment on function public.fn_hasta_dosya_no(integer) is
  'Siradaki hasta dosya numarasi (358): numara_sablonu tur 900 satirindan '
  'on ek + hane + baslangic okunur.';

create or replace function public.tg_taraf_hasta_dosya_no()
returns trigger
language plpgsql
as $$
declare v_elle smallint;
begin
    if coalesce(new.grup, 0) <> 101 then return new; end if;

    -- Numarayi kim verir: numara_sablonu (tur 900). Satir yoksa ELLE sayilir -
    --   kurulum yapilmamis sistemde kendiliginden numara uretmek yanlis olurdu.
    v_elle := coalesce((select s.elle_girilir
                          from public.fn_numara_sablonu_bul(900, coalesce(new.sube_id, 0),
                                                            current_date) s
                         limit 1), 1);

    if coalesce(btrim(new.kod), '') <> '' then
        return new;                     -- kullanici numara yazmis, aynen korunur
    end if;
    if v_elle = 1 then
        raise exception 'Hasta dosya numarası zorunlu (otomatik üretim kapalı). Numaralandırma ayarlarından açabilirsiniz.'
              using errcode = 'GK422';
    end if;
    new.kod := public.fn_hasta_dosya_no(coalesce(new.sube_id, 0));
    return new;
end $$;

drop trigger if exists tr_taraf_hasta_dosya_no on public.taraf;
create trigger tr_taraf_hasta_dosya_no before insert on public.taraf
    for each row execute function public.tg_taraf_hasta_dosya_no();

-- 356'nin sequence'i ve referans ayarlari kaldirilir (numara_sablonu'na tasindi).
drop sequence if exists public.hasta_dosya_no_seq;
delete from public.referans
 where anahtar in ('hasta.dosya_no_otomatik', 'basvuru.protokol_no_otomatik');

-- Yardim metinleri de yeni yere isaret etsin.
delete from public.help
 where anahtar in ('ayar.hasta.dosya_no_otomatik', 'ayar.basvuru.protokol_no_otomatik');
