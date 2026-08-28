-- ============================================================================
--  Gentegre AI — HESAP SATIRINA TABAN SATIR IZI (taban_satir_id)
--  211_taban_satir_izi.sql
--
--  Kullanici istegi: iz liste degil SATIR duzeyinde de tutulsun. taban_liste_id
--  KALIR (Manuel ezmenin kurali + liste izi); yeni taban_satir_id fiyatin
--  hangi YAZILI satirdan turedigini isaretler. Gerekce: taban listede ayni
--  kalemin birden cok satiri olabilir (ayni hizmet TL + USD, ayni stok farkli
--  birim - tekillik liste+kalem+birim+doviz) ve fn `limit 1` ile hangisini
--  aldigini soylemiyordu.
--
--  - FK ayni tabloya, on delete set null: taban satir silinirse iz kopar,
--    kayit kalir (bir sonraki uretim tazeler).
--  - Taban fiyat SATIRSIZ da cozulebilir (taban listede kalem yazili degilse
--    kural isler; kok listede kart fiyati) - o durumda iz bos kalir.
--  - fn donusune kaynak_satir_id eklendi: yazili-satir dalinda kendi satiri,
--    hesap dalinda TABAN cagrisindan gelen satir (zincirde en son yazili
--    satir). Donus tipi degistigi icin drop + create.
-- ============================================================================

alter table public.fiyat_listesi_satir
    add column if not exists taban_satir_id integer
        references public.fiyat_listesi_satir(id) on delete set null;

comment on column public.fiyat_listesi_satir.taban_satir_id is
  'Uretim izi: fiyatin turedigi yazili taban satiri (211). Kural degil - '
  'ezme taban_liste_id + Manuel ile. Taban kuraldan/karttan cozulduyse bos.';

create index if not exists ix_sls_taban_satir
    on public.fiyat_listesi_satir (taban_satir_id)
    where taban_satir_id is not null;

-- ---------------------------------------------------------------------------
-- 1) fn_fiyat_listesi_fiyat: donuse kaynak_satir_id eklendi.
-- ---------------------------------------------------------------------------
drop function if exists public.fn_fiyat_listesi_fiyat(integer, integer, integer, integer, boolean);

create function public.fn_fiyat_listesi_fiyat(
    p_liste_id  integer,
    p_stok_id   integer default null,
    p_hizmet_id integer default null,
    p_derinlik  integer default 0,
    p_yazili    boolean default true)
returns table(
    fiyat             numeric,
    doviz_cinsi       varchar(5),
    kdv_dahil         smallint,
    kaynak            text,
    taban             numeric,
    carpan_kullanilan numeric,
    -- 211: fiyatin okundugu YAZILI satir; hesap dalinda taban zincirindeki
    --   son yazili satir (uretim bunu taban_satir_id izine yazar).
    kaynak_satir_id   integer)
language plpgsql stable
as $$
declare
    l          public.fiyat_listesi%rowtype;
    r          public.fiyat_listesi_satir%rowtype;
    v_taban    numeric;
    v_doviz    varchar(5);
    v_tbn_kdv  smallint;
    v_tbn_sid  integer;
    v_kdv      numeric := 0;
    v_carpan   numeric;
    v_yon      smallint;
    v_adim     numeric;
    v_taban_id integer;
    v_manuel   boolean;
begin
    -- Zincir korumasi: 201'deki tetik dongulari engelliyor ama listeler elle
    --   (COPY / restore) da yazilabilir - hesap burada da kendini korur.
    if p_derinlik > 20 then
        raise exception 'Fiyat listesi zinciri 20 adimi asti (liste %).', p_liste_id;
    end if;

    select * into l from public.fiyat_listesi where id = p_liste_id;
    if not found then return; end if;

    -- 1) Listede YAZILI satir
    if p_yazili then
        select * into r from public.fiyat_listesi_satir
         where liste_id = p_liste_id and durum = 1
           and (p_stok_id   is not null and stok_id   = p_stok_id
             or p_hizmet_id is not null and hizmet_id = p_hizmet_id)
         limit 1;

        if found and (r.yazim = 1 or r.fiyat > 0) then
            return query select r.fiyat, r.doviz_cinsi, r.kdv_dahil,
                                case when r.yazim = 1 then 'satir-manuel' else 'satir-hesap' end,
                                nullif(r.taban_fiyat, 0), r.carpan, r.id;
            return;
        end if;
    else
        -- Yazili satir atlanacak; satirin ezmeleri icin yine de okunur.
        select * into r from public.fiyat_listesi_satir
         where liste_id = p_liste_id
           and (p_stok_id   is not null and stok_id   = p_stok_id
             or p_hizmet_id is not null and hizmet_id = p_hizmet_id)
         limit 1;
    end if;

    -- 2) Kural. Satir ezmesi YALNIZ MANUEL satirda (209): hesap satirindaki
    --    carpan/taban uretim IZIdir, kural degildir.
    v_manuel   := r.id is not null and r.yazim = 1;
    v_taban_id := case when v_manuel then coalesce(r.taban_liste_id, l.taban_liste_id)
                       else l.taban_liste_id end;
    v_carpan   := case when v_manuel then coalesce(r.carpan, l.carpan)
                       else l.carpan end;
    v_yon      := case when v_manuel then coalesce(r.yuvarlama, l.yuvarlama)
                       else l.yuvarlama end;
    v_adim     := case when v_manuel then coalesce(r.yuvarlama_birim, l.yuvarlama_birim)
                       else l.yuvarlama_birim end;

    if v_taban_id is not null then
        select t.fiyat, t.doviz_cinsi, t.kdv_dahil, t.kaynak_satir_id
          into v_taban, v_doviz, v_tbn_kdv, v_tbn_sid
          from public.fn_fiyat_listesi_fiyat(v_taban_id, p_stok_id, p_hizmet_id, p_derinlik + 1, true) t;
    else
        -- KOK liste: kalemin kart fiyati, LISTENIN YONUNDE. Satir izi yok.
        select k.fiyat, k.doviz_cinsi, k.kdv_dahil
          into v_taban, v_doviz, v_tbn_kdv
          from public.fn_kalem_kart_fiyati(p_stok_id, p_hizmet_id, l.yon) k;
        v_tbn_sid := null;
    end if;

    if v_taban is null then return; end if;

    -- KDV orani kalemin kendi kartindan (stok.kdv / hizmet.kdv)
    select coalesce(s.kdv, h.kdv, 0) into v_kdv
      from (select 1) x
      left join public.stok   s on s.id = p_stok_id
      left join public.hizmet h on h.id = p_hizmet_id;

    v_taban := public.fn_kdv_cevir(v_taban, v_tbn_kdv, l.kdv_dahil, v_kdv);

    return query
      select public.fn_fiyat_yuvarla(v_taban * v_carpan, v_yon, v_adim),
             coalesce(v_doviz, 'TL')::varchar(5),
             l.kdv_dahil,
             'hesap'::text,
             v_taban,
             v_carpan,
             v_tbn_sid;
end $$;

comment on function public.fn_fiyat_listesi_fiyat(integer, integer, integer, integer, boolean) is
  'Kalemin liste fiyati. Once yazili satir; yoksa kural: taban liste (rekursif) '
  'ya da kok listede kart fiyati -> KDV cevir -> x carpan -> yuvarla. Satir kural '
  'ezmesi yalniz Manuel (yazim=1) satirda; taban/carpan_kullanilan/kaynak_satir_id '
  'hesap izidir (209/211).';

-- ---------------------------------------------------------------------------
-- 2) fn_fiyat_listesi_uret: taban_satir_id izi de yazilir.
-- ---------------------------------------------------------------------------
create or replace function public.fn_fiyat_listesi_uret(
    p_liste_id integer, p_kullanici integer default 0,
    p_stok boolean default true, p_hizmet boolean default true)
returns table(eklenen integer, guncellenen integer, korunan integer, fiyatsiz integer)
language plpgsql
as $$
declare
    l          public.fiyat_listesi%rowtype;
    v_ekle     integer := 0;
    v_guncelle integer := 0;
    v_koru     integer := 0;
    v_yok      integer := 0;
    k          record;
    v_f        record;
begin
    select * into l from public.fiyat_listesi where id = p_liste_id;
    if not found then
        raise exception 'Fiyat listesi bulunamadi: %', p_liste_id;
    end if;

    select count(*) into v_koru from public.fiyat_listesi_satir
     where liste_id = p_liste_id and yazim = 1;

    -- Kalem kumesi: aktif stoklar + aktif hizmetler. Baslik satiri olan
    --   hizmetler (baslik_mi = 1) fiyatlandirilmaz - onlar gruplama satiri.
    for k in
        select s.id as stok_id, null::integer as hizmet_id, s.ana_birim as birim
          from public.stok s
         where p_stok and s.durum = 1
        union all
        select null, h.id, h.birim
          from public.hizmet h
         where p_hizmet and h.durum = 1 and coalesce(h.baslik_mi, 0) = 0
    loop
        -- ZINCIRLI listede kalem TABANDA YAZILI DEGILSE ATLANIR (209).
        if l.taban_liste_id is not null then
            perform 1 from public.fiyat_listesi_satir t
              where t.liste_id = l.taban_liste_id and t.durum = 1 and t.fiyat > 0
                and (k.stok_id   is not null and t.stok_id   = k.stok_id
                  or k.hizmet_id is not null and t.hizmet_id = k.hizmet_id);
            if not found then
                v_yok := v_yok + 1;
                continue;
            end if;
        end if;

        -- p_yazili = false: kural yeniden isletilsin, kendi eski satirini okumasin.
        select * into v_f
          from public.fn_fiyat_listesi_fiyat(p_liste_id, k.stok_id, k.hizmet_id, 0, false);

        -- Fiyati cozulemeyen kalem ATLANIR: 0 TL'lik satir yazmak, listeyi
        --   "bedava" gosteren bir tuzak olurdu.
        if v_f.fiyat is null or v_f.fiyat <= 0 then
            v_yok := v_yok + 1;
            continue;
        end if;

        insert into public.fiyat_listesi_satir
            (liste_id, stok_id, hizmet_id, fiyat, doviz_cinsi, kdv_dahil, birim,
             durum, yazim, taban_fiyat, carpan, taban_liste_id, taban_satir_id,
             uretim_tarihi, ekleyen, degistiren)
        values
            (p_liste_id, k.stok_id, k.hizmet_id, v_f.fiyat, v_f.doviz_cinsi, v_f.kdv_dahil,
             coalesce(k.birim, 0), 1, 2,
             coalesce(v_f.taban, v_f.fiyat), v_f.carpan_kullanilan,
             l.taban_liste_id, v_f.kaynak_satir_id,
             now()::timestamp, p_kullanici, p_kullanici)
        on conflict do nothing;

        if found then
            v_ekle := v_ekle + 1;
        else
            -- Var olan satir: yalniz HESAP satirlari guncellenir; taban/carpan/
            --   taban_liste_id/taban_satir_id guncel kuralin IZIyle tazelenir.
            update public.fiyat_listesi_satir
               set fiyat = v_f.fiyat, doviz_cinsi = v_f.doviz_cinsi, kdv_dahil = v_f.kdv_dahil,
                   taban_fiyat = coalesce(v_f.taban, v_f.fiyat),
                   carpan = v_f.carpan_kullanilan,
                   taban_liste_id = l.taban_liste_id,
                   taban_satir_id = v_f.kaynak_satir_id,
                   uretim_tarihi = now()::timestamp,
                   degistiren = p_kullanici
             where liste_id = p_liste_id and yazim = 2
               and (k.stok_id   is not null and stok_id   = k.stok_id
                 or k.hizmet_id is not null and hizmet_id = k.hizmet_id);
            if found then v_guncelle := v_guncelle + 1; end if;
        end if;
    end loop;

    return query select v_ekle, v_guncelle, v_koru, v_yok;
end $$;

-- ---------------------------------------------------------------------------
-- 3) Mevcut hesap satirlarina taban satir izi yazilir (fn ile ayni cozum).
-- ---------------------------------------------------------------------------
do $$
declare
    s     record;
    v     record;
    v_duz integer := 0;
begin
    for s in select id, liste_id, stok_id, hizmet_id
               from public.fiyat_listesi_satir where yazim = 2
    loop
        select * into v
          from public.fn_fiyat_listesi_fiyat(s.liste_id, s.stok_id, s.hizmet_id, 0, false);
        if v.kaynak_satir_id is null then continue; end if;

        update public.fiyat_listesi_satir
           set taban_satir_id = v.kaynak_satir_id
         where id = s.id and taban_satir_id is distinct from v.kaynak_satir_id;
        if found then v_duz := v_duz + 1; end if;
    end loop;

    raise notice '211 tamam: % hesap satirina taban satir izi yazildi.', v_duz;
end $$;
