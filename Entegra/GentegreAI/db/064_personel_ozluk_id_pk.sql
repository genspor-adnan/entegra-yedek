-- ============================================================================
--  Gentegre AI - Personel ozluk 1:1 anahtar duzeltmesi
--  064_personel_ozluk_id_pk.sql
--  taraf_personel.taraf_id kaldirilir; id dogrudan taraf.id olur.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
declare
    v_sube_id integer;
begin
    if exists (
        select 1
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'taraf_personel'
          and column_name = 'taraf_id'
    ) then
        select id into v_sube_id
        from public.sube
        order by varsayilan desc, id
        limit 1;

        alter table public.taraf_personel rename to personel_ozluk_eski_064;
        alter table public.personel_ozluk_eski_064 drop constraint if exists personel_ozluk_pkey;
        alter table public.personel_ozluk_eski_064 drop constraint if exists personel_ozluk_pkey_id;
        alter table public.personel_ozluk_eski_064 drop constraint if exists ux_personel_ozluk_taraf;
        alter table public.personel_ozluk_eski_064 drop constraint if exists personel_ozluk_taraf_id_fkey;
        alter table public.personel_ozluk_eski_064 drop constraint if exists fk_personel_ozluk_sube_id;
        alter table public.personel_ozluk_eski_064 drop constraint if exists personel_ozluk_sube_id_fkey;
        alter table public.personel_ozluk_eski_064 drop constraint if exists personel_ozluk_yonetici_taraf_id_fkey;

        create table public.taraf_personel (
            id                   integer primary key references public.taraf(id) on delete cascade,
            sicil_no             character varying(20)  not null default '',
            dogum_tarihi         date,
            cinsiyet             smallint not null default 0,
            gorev                character varying(100) not null default '',
            departman            smallint not null default 0,
            ise_giris_tarihi     date,
            isten_cikis_tarihi   date,
            sube_id              integer not null references public.sube(id),
            ekleyen              integer not null default 0,
            ekleme_tarihi        timestamp not null default now()::timestamp,
            degistiren           integer not null default 0,
            degistirme_tarihi    timestamp,
            calisma_sekli        smallint not null default 0,
            uyruk                character varying(60) not null default 'TC',
            vardiya_turu         smallint not null default 0,
            sgk_baslama_tarihi   date,
            medeni_hal           smallint not null default 0,
            kan_grubu            smallint not null default 0,
            sozlesme_turu        smallint not null default 0,
            deneme_suresi        smallint not null default 0,
            dogum_yeri           character varying(60) not null default '',
            sgk_sicil_no         character varying(30) not null default '',
            meslek_kodu          character varying(60) not null default '',
            yonetici_taraf_id    integer references public.taraf(id)
        );

        insert into public.taraf_personel (
            id, sicil_no, dogum_tarihi, cinsiyet, gorev, departman,
            ise_giris_tarihi, isten_cikis_tarihi, sube_id,
            ekleyen, ekleme_tarihi, degistiren, degistirme_tarihi,
            calisma_sekli, uyruk, vardiya_turu, sgk_baslama_tarihi,
            medeni_hal, kan_grubu, sozlesme_turu, deneme_suresi,
            dogum_yeri, sgk_sicil_no, meslek_kodu, yonetici_taraf_id
        )
        select
            taraf_id, sicil_no, dogum_tarihi, cinsiyet, gorev, departman,
            ise_giris_tarihi, isten_cikis_tarihi, coalesce(sube_id, v_sube_id),
            ekleyen, ekleme_tarihi, degistiren, degistirme_tarihi,
            calisma_sekli, uyruk, vardiya_turu, sgk_baslama_tarihi,
            medeni_hal, kan_grubu, sozlesme_turu, deneme_suresi,
            dogum_yeri, sgk_sicil_no, meslek_kodu, yonetici_taraf_id
        from public.personel_ozluk_eski_064;

        drop table public.personel_ozluk_eski_064;
    end if;
end $$;

comment on table public.taraf_personel is
  'Personel ozluk bilgileri. 1:1 iliski: id = taraf.id.';

