-- ============================================================================
--  Gentegre AI — FIYAT LISTESI HESABI VE URETIMI
--  202_fn_fiyat_listesi.sql
--
--  Kural TEK YERDE: "taban fiyat x carpan -> yuvarla". Ayni formulu hem liste
--  uretimi hem tekil fiyat sorgusu kullanir; iki yere yazilirsa uretilen liste
--  ile ekranda gorunen fiyat birbirinden kayar.
--
--  TABAN FIYAT NEREDEN GELIR
--    - Listenin taban_liste_id'si varsa: o listedeki AYNI kalemin fiyati.
--      (Zincir: bayi -> perakende -> kok. Dongu 201'deki tetikle engelli.)
--    - Taban liste yoksa (KOK liste): kalemin kendi fiyati -
--      stok icin fn_stok_kart_fiyat (128), hizmet icin hizmet_fiyat.
--
--  KDV: baslik "dahil" diyorsa uretilen fiyat KDV DAHIL yazilir. Taban fiyat
--  farkli KDV kabulundeyse cevrilir - iki listeyi karsilastiran kullanici
--  elmayla armudu toplamasin.
-- ============================================================================
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------------
--  YUVARLAMA - tek kural
--    0 Yok · 1 Yukari · 2 Asagi · 3 En Yakin
--  Hepsi ADIMA gore calisir (yuvarlama_birim): 0.01 kurusa, 1 liraya, 5 liraya.
-- ---------------------------------------------------------------------------
create or replace function public.fn_fiyat_yuvarla(
    p_tutar numeric,
    p_yon   smallint,
    p_adim  numeric default 1)
returns numeric
language sql immutable parallel safe as $$
    select case
        when p_tutar is null then null
        when coalesce(p_yon, 0) = 0 or coalesce(p_adim, 0) <= 0 then p_tutar
        when p_yon = 1 then ceil (p_tutar / p_adim) * p_adim
        when p_yon = 2 then floor(p_tutar / p_adim) * p_adim
        when p_yon = 3 then round(p_tutar / p_adim) * p_adim
        else p_tutar
    end
$$;

comment on function public.fn_fiyat_yuvarla(numeric, smallint, numeric) is
  'Fiyat yuvarlama (202): 0 yok / 1 yukari / 2 asagi / 3 en yakin - hepsi ADIM (yuvarlama_birim) uzerinden.';

-- ---------------------------------------------------------------------------
--  KOK FIYAT: kalemin kendi karti uzerindeki fiyat (liste zincirinin sonu).
-- ---------------------------------------------------------------------------
drop function if exists public.fn_kalem_kart_fiyati(integer, integer);

create or replace function public.fn_kalem_kart_fiyati(
    p_stok_id   integer,
    p_hizmet_id integer,
    -- YON SART: alis listesinin kok fiyati stogun ALIS kart fiyatidir. Sabit
    --   satis=1 yazilirsa alis listesi satis fiyatindan turer ve maliyet
    --   listesi satis fiyatiyla doldurulur - sessiz ve buyuk bir hata.
    p_yon       smallint default 2)      -- 1 alis, 2 satis
returns table (fiyat numeric, doviz_cinsi varchar, kdv_dahil smallint)
language sql stable parallel safe as $$
    -- Stok: kart fiyati (128 - en dusuk fiyat_adi, fiyat > 0). KDV HARIC
    --   tutulur (belge_satir da oyle hesaplar).
    select f.fiyat, f.doviz_cinsi, 0::smallint
      from public.fn_stok_kart_fiyat(p_stok_id, case when p_yon = 1 then 0 else 1 end::smallint) f
     where p_stok_id is not null
    union all
    -- Hizmet: en dusuk fiyat_adi, fiyat > 0. kdv_durum 1 = KDV dahil.
    select hf.fiyat, hf.doviz_cinsi, (hf.kdv_durum = 1)::int::smallint
      from public.hizmet_fiyat hf
     where p_hizmet_id is not null and hf.hizmet_id = p_hizmet_id and hf.fiyat > 0
     order by 1
     limit 1
$$;

comment on function public.fn_kalem_kart_fiyati(integer, integer, smallint) is
  'Kalemin KART fiyati (202) - fiyat listesi zincirinin kok degeri; yon 1 alis / 2 satis.';

-- ---------------------------------------------------------------------------
--  KDV cevrimi: taban fiyat ile hedef listenin KDV kabulu farkliysa duzeltir.
-- ---------------------------------------------------------------------------
create or replace function public.fn_kdv_cevir(
    p_tutar     numeric,
    p_kaynak    smallint,   -- 1 kaynak KDV dahil
    p_hedef     smallint,   -- 1 hedef KDV dahil
    p_kdv_orani numeric)
returns numeric
language sql immutable parallel safe as $$
    select case
        when p_tutar is null or coalesce(p_kaynak,0) = coalesce(p_hedef,0) then p_tutar
        when coalesce(p_hedef,0) = 1 then p_tutar * (1 + coalesce(p_kdv_orani,0) / 100.0)
        else p_tutar / (1 + coalesce(p_kdv_orani,0) / 100.0)
    end
$$;

-- ---------------------------------------------------------------------------
--  TEK KALEMIN LISTE FIYATI
--
--  Once listede YAZILI satir aranir (materyalize edilmis liste). Yoksa kural
--  zincirle isletilir - liste henuz uretilmemis olsa da ekran fiyat gosterebilsin.
-- ---------------------------------------------------------------------------
-- ESKI IMZAYI DUSUR: `create or replace` PARAMETRE EKLEYEMEZ - yeni bir asiri
--   yukleme yaratir ve iki aday arasinda PostgreSQL "function is not unique"
--   diyerek cagriyi reddeder. Once eski surum silinir.
drop function if exists public.fn_fiyat_listesi_fiyat(integer, integer, integer, integer);

create or replace function public.fn_fiyat_listesi_fiyat(
    p_liste_id  integer,
    p_stok_id   integer default null,
    p_hizmet_id integer default null,
    p_derinlik  integer default 0,
    -- YAZILI SATIRI KULLAN: normalde evet (materyalize liste zaten odur).
    --   Listeyi YENIDEN URETIRKEN hayir olmali - yoksa uretim kendi yazdigi
    --   satiri okur, kurali bir daha hic isletmez ve liste TAZELENEMEZ
    --   (taban fiyat/carpan degisse bile eski deger yerinde kalir).
    --   Zincirdeki TABAN listeler icin yine evet: onlarin materyalize hali
    --   dogru cevaptir.
    p_yazili    boolean default true)
returns table (fiyat numeric, doviz_cinsi varchar, kdv_dahil smallint, kaynak text)
language plpgsql stable as $$
declare
    l          public.fiyat_listesi%rowtype;
    r          public.fiyat_listesi_satir%rowtype;
    v_taban    numeric;
    v_doviz    varchar(5);
    v_tbn_kdv  smallint;
    v_kdv      numeric := 0;
    v_carpan   numeric;
    v_yon      smallint;
    v_adim     numeric;
    v_taban_id integer;
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
                            case when r.yazim = 1 then 'satir-manuel' else 'satir-hesap' end;
        return;
    end if;
    else
        -- Yazili satir atlanacak; yine de SATIR SEVIYESI KURAL EZMESI okunur
        --   (satirin kendi taban/carpan/yuvarlamasi uretimde de gecerli).
        select * into r from public.fiyat_listesi_satir
         where liste_id = p_liste_id
           and (p_stok_id   is not null and stok_id   = p_stok_id
             or p_hizmet_id is not null and hizmet_id = p_hizmet_id)
         limit 1;
    end if;

    -- 2) Kural: satirda ezme varsa o, yoksa basligin kurali
    v_taban_id := coalesce(r.taban_liste_id, l.taban_liste_id);
    v_carpan   := coalesce(r.carpan,          l.carpan);
    v_yon      := coalesce(r.yuvarlama,       l.yuvarlama);
    v_adim     := coalesce(r.yuvarlama_birim, l.yuvarlama_birim);

    if v_taban_id is not null then
        select t.fiyat, t.doviz_cinsi, t.kdv_dahil
          into v_taban, v_doviz, v_tbn_kdv
          from public.fn_fiyat_listesi_fiyat(v_taban_id, p_stok_id, p_hizmet_id, p_derinlik + 1, true) t;
    else
        -- KOK liste: kalemin kart fiyati, LISTENIN YONUNDE.
        select k.fiyat, k.doviz_cinsi, k.kdv_dahil
          into v_taban, v_doviz, v_tbn_kdv
          from public.fn_kalem_kart_fiyati(p_stok_id, p_hizmet_id, l.yon) k;
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
             'hesap'::text;
end $$;

comment on function public.fn_fiyat_listesi_fiyat(integer, integer, integer, integer, boolean) is
  'Kalemin liste fiyati (202): once yazili satir, yoksa taban zinciri x carpan -> yuvarlama.';

-- ---------------------------------------------------------------------------
--  LISTEYI URET (materyalize)
--
--  Kullanici karari: satirlar YAZILIR. Bu yuzden taban fiyat degistiginde liste
--  bayatlar ve bu fonksiyonun yeniden calistirilmasi gerekir.
--
--  KORUNAN: `yazim = 1` (manuel) satirlar. Elle girilen fiyati hesapla ezmek,
--  kullanicinin bilerek yaptigi istisnayi sessizce silmek olurdu.
-- ---------------------------------------------------------------------------
create or replace function public.fn_fiyat_listesi_uret(
    p_liste_id  integer,
    p_kullanici integer default 0,
    p_stok      boolean default true,
    p_hizmet    boolean default true)
returns table (eklenen integer, guncellenen integer, korunan integer, fiyatsiz integer)
language plpgsql as $$
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
             durum, yazim, taban_fiyat, uretim_tarihi, ekleyen, degistiren)
        values
            (p_liste_id, k.stok_id, k.hizmet_id, v_f.fiyat, v_f.doviz_cinsi, v_f.kdv_dahil,
             coalesce(k.birim, 0), 1, 2, v_f.fiyat, now()::timestamp, p_kullanici, p_kullanici)
        on conflict do nothing;

        if found then
            v_ekle := v_ekle + 1;
        else
            -- Var olan satir: yalniz HESAP satirlari guncellenir.
            update public.fiyat_listesi_satir
               set fiyat = v_f.fiyat, doviz_cinsi = v_f.doviz_cinsi, kdv_dahil = v_f.kdv_dahil,
                   taban_fiyat = v_f.fiyat, uretim_tarihi = now()::timestamp,
                   degistiren = p_kullanici
             where liste_id = p_liste_id and yazim = 2
               and (k.stok_id   is not null and stok_id   = k.stok_id
                 or k.hizmet_id is not null and hizmet_id = k.hizmet_id);
            if found then v_guncelle := v_guncelle + 1; end if;
        end if;
    end loop;

    return query select v_ekle, v_guncelle, v_koru, v_yok;
end $$;

comment on function public.fn_fiyat_listesi_uret(integer, integer, boolean, boolean) is
  'Listeyi materyalize eder (202): hesap satirlarini yazar/gunceller, MANUEL satirlari korur.';

do $$
begin
    raise notice '202 tamam: fn_fiyat_yuvarla / fn_kalem_kart_fiyati / fn_fiyat_listesi_fiyat / fn_fiyat_listesi_uret.';
end $$;
