-- ============================================================================
--  Gentegre AI — YAZIM GECIS KURALLARI (satir tetigi v2)
--  212_yazim_gecis_kurali.sql
--
--  Kullanici kurallari (28.08.2026):
--   1. Satirin CARPANI degisince: fiyat = taban_fiyat x yeni carpan
--      (taban_fiyat DEGISMEZ) ve satir MANUEL olur. (211'deki tetik - kalir.)
--   2. Yazim MANUEL -> HESAP'a cevrilince: fiyat basligin kuralindan YENIDEN
--      cozulur (taban listedeki guncel fiyattan), taban/carpan/taban_satir
--      izleri tazelenir - "fiyati satirdan bulup hesaplayip tekrar yazmali".
--
--  Bunun icin fn_fiyat_listesi_fiyat'a p_ezme parametresi eklendi: tetik
--  Manuel -> Hesap gecisinde satirin ESKI manuel carpanini kural sanmasin
--  diye ezmeleri kapatip (p_ezme = false) saf baslik kuralini ister. Donus
--  tipi ayni, yalniz parametre eklendigi icin eski imza drop edilir
--  ("function is not unique" tuzagi).
--
--  Ayni kurallarin EKRAN kopyasi GenForm.fiyatSatirKurali'nda: kullanici
--  sonucu kaydetmeden gorur ve fiyat/yazim istekle birlikte gidip islem
--  loguna yazilir; DB tetigi son otorite kalir.
-- ============================================================================

drop function if exists public.fn_fiyat_listesi_fiyat(integer, integer, integer, integer, boolean);

create function public.fn_fiyat_listesi_fiyat(
    p_liste_id  integer,
    p_stok_id   integer default null,
    p_hizmet_id integer default null,
    p_derinlik  integer default 0,
    p_yazili    boolean default true,
    -- false: satir kural ezmelerini de yok say (Manuel -> Hesap gecisi saf
    --   baslik kuralini ister). Varsayilan davranis degismez.
    p_ezme      boolean default true)
returns table(
    fiyat             numeric,
    doviz_cinsi       varchar(5),
    kdv_dahil         smallint,
    kaynak            text,
    taban             numeric,
    carpan_kullanilan numeric,
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

    -- 2) Kural. Satir ezmesi YALNIZ MANUEL satirda (209) ve p_ezme aciksa:
    --    hesap satirindaki carpan/taban uretim IZIdir, kural degildir.
    v_manuel   := p_ezme and r.id is not null and r.yazim = 1;
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

comment on function public.fn_fiyat_listesi_fiyat(integer, integer, integer, integer, boolean, boolean) is
  'Kalemin liste fiyati. Once yazili satir; yoksa kural: taban liste (rekursif) '
  'ya da kok listede kart fiyati -> KDV cevir -> x carpan -> yuvarla. Satir kural '
  'ezmesi yalniz Manuel (yazim=1) satirda ve p_ezme aciksa; taban/carpan_kullanilan/'
  'kaynak_satir_id hesap izidir (209/211/212).';

-- ---------------------------------------------------------------------------
-- Tetik v2: carpan degisimi (Manuel yapar) + yazim Manuel -> Hesap (kuraldan
-- tam tazeleme). Uretimin update'i uretim_tarihi degistirdigi icin atlanir.
-- ---------------------------------------------------------------------------
create or replace function public.fn_sls_carpan_manuel()
returns trigger language plpgsql
as $$
declare
    v record;
begin
    if new.uretim_tarihi is distinct from old.uretim_tarihi then
        return new;   -- uretimin yazisi, kullanici duzenlemesi degil
    end if;

    -- 1) MANUEL -> HESAP: fiyat basligin kuralindan yeniden cozulur (taban
    --    listedeki GUNCEL fiyat), izler tazelenir. p_ezme = false: satirin
    --    eski manuel carpani kural sayilmasin.
    if old.yazim = 1 and new.yazim = 2 then
        select * into v from public.fn_fiyat_listesi_fiyat(
            new.liste_id, new.stok_id, new.hizmet_id, 0, false, false);
        if v.fiyat is not null and v.fiyat > 0 then
            new.fiyat          := v.fiyat;
            new.taban_fiyat    := coalesce(v.taban, v.fiyat);
            new.carpan         := v.carpan_kullanilan;
            new.taban_satir_id := v.kaynak_satir_id;
            new.taban_liste_id := (select fl.taban_liste_id
                                     from public.fiyat_listesi fl
                                    where fl.id = new.liste_id);
        end if;
        return new;
    end if;

    -- 2) CARPAN degisti: satir MANUEL olur, fiyat = taban_fiyat x yeni carpan
    --    (taban_fiyat DEGISMEZ; yuvarlama satirdan, bossa basliktan).
    if new.carpan is distinct from old.carpan then
        new.yazim := 1;
        if new.carpan is not null and new.carpan > 0
           and coalesce(new.taban_fiyat, 0) > 0 then
            select public.fn_fiyat_yuvarla(new.taban_fiyat * new.carpan,
                       coalesce(new.yuvarlama, fl.yuvarlama),
                       coalesce(new.yuvarlama_birim, fl.yuvarlama_birim))
              into new.fiyat
              from public.fiyat_listesi fl
             where fl.id = new.liste_id;
        end if;
    end if;
    return new;
end $$;

do $$ begin
    raise notice '212 tamam: fn_fiyat_listesi_fiyat + p_ezme; tetik v2 (carpan -> Manuel, Manuel -> Hesap tazeleme).';
end $$;
