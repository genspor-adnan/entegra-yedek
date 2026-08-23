-- ============================================================================
--  Gentegre AI - 1:1 taraf rol tablolarinda id kolonu
--  068_taraf_rol_id_kolonlari.sql
--  taraf_kullanici/taraf_musteri/taraf_tedarikci taraf_id kolonlari id olur.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
begin
    if exists (
        select 1 from information_schema.columns
        where table_schema = 'public' and table_name = 'taraf_kullanici'
          and column_name = 'taraf_id'
    ) and not exists (
        select 1 from information_schema.columns
        where table_schema = 'public' and table_name = 'taraf_kullanici'
          and column_name = 'id'
    ) then
        alter table public.taraf_kullanici rename column taraf_id to id;
    end if;

    if exists (
        select 1 from information_schema.columns
        where table_schema = 'public' and table_name = 'taraf_musteri'
          and column_name = 'taraf_id'
    ) and not exists (
        select 1 from information_schema.columns
        where table_schema = 'public' and table_name = 'taraf_musteri'
          and column_name = 'id'
    ) then
        alter table public.taraf_musteri rename column taraf_id to id;
    end if;

    if exists (
        select 1 from information_schema.columns
        where table_schema = 'public' and table_name = 'taraf_tedarikci'
          and column_name = 'taraf_id'
    ) and not exists (
        select 1 from information_schema.columns
        where table_schema = 'public' and table_name = 'taraf_tedarikci'
          and column_name = 'id'
    ) then
        alter table public.taraf_tedarikci rename column taraf_id to id;
    end if;
end $$;

create or replace function public.fn_kullanici_yetkileri(p_kullanici_id integer)
returns table (yetki_kod varchar, tur smallint, gor smallint, ekle smallint, degistir smallint, sil smallint)
language sql stable as $$
    select y.kod, y.tur, ry.gor, ry.ekle, ry.degistir, ry.sil
      from public.taraf_kullanici k
      join public.rol_yetki ry on ry.rol_id = k.rol_id
      join public.yetki y      on y.id = ry.yetki_id and y.aktif = 1
     where k.id = p_kullanici_id
       and k.aktif = 1
       and (ry.gor = 1 or ry.ekle = 1 or ry.degistir = 1 or ry.sil = 1)
$$;

create or replace function public.fn_parola_ata(p_kullanici_id integer, p_parola text,
                                                p_degismeli smallint default 0)
returns void
language sql as $$
    update public.taraf_kullanici
       set parola_hash      = crypt(p_parola, gen_salt('bf', 12)),
           parola_algo      = 'bcrypt',
           parola_tarihi    = now()::timestamp,
           parola_degismeli = p_degismeli,
           hatali_giris     = 0,
           kilit_bitis      = null
     where id = p_kullanici_id
$$;

comment on table public.taraf_kullanici is
  'Uygulama kullanicisi. id = personel rollu taraf kaydi (eski KULLANICI.REHBERID). Kullanici TEK role baglidir.';
comment on table public.taraf_musteri is
  'Musteri rolu 1:1 uzanti bilgileri. id = taraf.id.';
comment on table public.taraf_tedarikci is
  'Tedarikci rolu 1:1 uzanti bilgileri. id = taraf.id.';
