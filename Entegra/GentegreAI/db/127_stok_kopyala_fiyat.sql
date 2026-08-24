-- ============================================================================
--  Gentegre AI — STOK KOPYALAMAYA FIYATLAR DA DAHIL
--  127_stok_kopyala_fiyat.sql
--
--  126'da fiyat listesi bilerek disarida birakilmisti (yanlis urune ait fiyatla
--  satis riski). Kullanici tersini istedi: kopyalanan kart cogunlukla ayni
--  urunun varyanti oluyor, fiyat da neredeyse ayni - elle yeniden girmek hem
--  zaman kaybi hem unutma riski. Fiyat artik KOPYALANIR.
--
--  BARKOD hala kopyalanmaz: barkod fiziksel olarak TEK urune aittir, iki karta
--  ayni barkodu yazmak okutmada hangi karta gidilecegini belirsiz birakir.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_stok_kopyala(
    p_stok_id   integer,
    p_kullanici integer default 0,
    p_sube_id   integer default null)
returns integer
language plpgsql as $$
declare
    v_kolonlar text;
    v_kod      varchar(30);
    v_ad       varchar(200);
    v_yeni     integer;
    v_sira     integer := 1;
begin
    select kod, ad into v_kod, v_ad from public.stok where id = p_stok_id;
    if v_kod is null then
        raise exception 'Kopyalanacak stok bulunamadi (%).', p_stok_id
              using errcode = 'no_data_found';
    end if;

    -- Bos olmayan ilk "_Kn" bulunur. Kod kolonu 30 karakter: sonek icin yer
    --   yoksa bastan kirpilir, yoksa insert uzunluk hatasi verirdi.
    loop
        exit when not exists (
            select 1 from public.stok
             where kod = left(v_kod, 30 - length('_K' || v_sira)) || '_K' || v_sira);
        v_sira := v_sira + 1;
    end loop;
    v_kod := left(v_kod, 30 - length('_K' || v_sira)) || '_K' || v_sira;
    v_ad  := left(v_ad, 200 - length(' kopya')) || ' kopya';

    select string_agg(quote_ident(column_name), ', ' order by ordinal_position)
      into v_kolonlar
      from information_schema.columns
     where table_schema = 'public' and table_name = 'stok'
       and column_name not in ('id', 'kod', 'ad',
                               'ekleyen', 'ekleme_tarihi',
                               'degistiren', 'degistirme_tarihi');

    execute format(
        'insert into public.stok (kod, ad, ekleyen, ekleme_tarihi, %1$s)
         select $1, $2, $3, now()::timestamp, %1$s
           from public.stok where id = $4
         returning id', v_kolonlar)
      into v_yeni
     using v_kod, v_ad, p_kullanici, p_stok_id;

    if p_sube_id is not null then
        update public.stok set sube_id = p_sube_id where id = v_yeni;
    end if;

    -- Paket icerigi (124/125).
    insert into public.stok_paket (paket_stok_id, icerik_stok_id, sira, birim,
                                   adet, birim_fiyat, doviz_cinsi,
                                   ekleyen, ekleme_tarihi)
    select v_yeni, icerik_stok_id, sira, birim, adet, birim_fiyat, doviz_cinsi,
           p_kullanici, now()::timestamp
      from public.stok_paket
     where paket_stok_id = p_stok_id;

    -- FIYAT LISTESI (127): alis/satis, fiyat adi, birim ve doviz aynen gelir.
    insert into public.stok_fiyat (stok_id, fiyat_adi, birim, fiyat, doviz_cinsi,
                                   satis, ekleyen, ekleme_tarihi)
    select v_yeni, fiyat_adi, birim, fiyat, doviz_cinsi, satis,
           p_kullanici, now()::timestamp
      from public.stok_fiyat
     where stok_id = p_stok_id;

    return v_yeni;
end $$;

comment on function public.fn_stok_kopyala(integer, integer, integer) is
  'Stok kartini kopyalar (126/127): kod "_Kn", ad " kopya"; paket icerigi ve fiyat listesi kopyalanir, barkod kopyalanmaz.';

do $$
begin
    raise notice '127 tamam: fn_stok_kopyala fiyatlari da kopyaliyor';
end $$;
