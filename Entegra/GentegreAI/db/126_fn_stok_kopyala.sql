-- ============================================================================
--  Gentegre AI — STOK KARTI KOPYALA
--  126_fn_stok_kopyala.sql
--
--  Benzer urunler (ayni urunun farkli olcusu, ayni paketin baska varyanti)
--  bugune kadar sifirdan giriliyordu: on alan elle yeniden dolduruluyor, biri
--  unutuluyordu. Kopyala aksiyonu karti oldugu gibi cogaltir; kullanici yalniz
--  degisen alani duzeltir.
--
--  KOD/AD: kod sonuna "_K1" (dolu ise _K2, _K3...), ad sonuna " kopya" eklenir -
--  iki kart listede birbirine karismasin ve kod benzersizligi bozulmasin.
--
--  KOLON LISTESI DINAMIK: stok tablosuna ileride kolon eklendiginde bu fonksiyon
--  guncellenmek zorunda kalmasin diye kolonlar information_schema'dan okunur.
--  Yalniz kimlik (id), ad/kod ve audit dortlusu disarida birakilir.
--
--  PAKET ICERIGI de kopyalanir (124/125): paket kartinin kopyasi bos icerikle
--  acilsa kopyalamanin anlami kalmazdi. Diger detaylar (fiyat, barkod, ÜTS)
--  BILEREK kopyalanmaz - fiyat listesi ve barkod urune OZELDIR, kopyalanirsa
--  yanlis urune ait fiyatla satis yapilirdi.
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

    insert into public.stok_paket (paket_stok_id, icerik_stok_id, sira, birim,
                                   adet, birim_fiyat, doviz_cinsi,
                                   ekleyen, ekleme_tarihi)
    select v_yeni, icerik_stok_id, sira, birim, adet, birim_fiyat, doviz_cinsi,
           p_kullanici, now()::timestamp
      from public.stok_paket
     where paket_stok_id = p_stok_id;

    return v_yeni;
end $$;

comment on function public.fn_stok_kopyala(integer, integer, integer) is
  'Stok kartini kopyalar (126): kod "_Kn", ad " kopya"; paket icerigi de kopyalanir, fiyat/barkod kopyalanmaz.';

do $$
begin
    raise notice '126 tamam: fn_stok_kopyala hazir';
end $$;
