-- ============================================================================
--  Gentegre AI — SATIRDA TABAN FIYAT + CARPAN IZI (kullanici istegi)
--  209_taban_fiyat_izi.sql
--
--  Once: uretim taban_fiyat kolonuna NIHAI fiyatin kopyasini yaziyordu
--  (taban_fiyat = fiyat) ve carpan'i bos birakiyordu - TTB2018 (x7,0092)
--  satirinda "taban 1.752,30" gorunuyordu, oysa taban Puan listesindeki 250.
--
--  Simdi (hesap / yazim = 2 satirlarinda):
--    taban_fiyat = carpan ONCESI taban (KDV cevrimi sonrasi) - DEGISMEZ IZ
--    carpan      = uretimde kullanilan carpan (iz)
--    fiyat       = fn_fiyat_yuvarla(taban_fiyat * carpan)
--
--  SEMANTIK DEGISIKLIGI - satir kural ezmesi yalniz MANUEL satirda:
--  Hesap satirina carpan yazilinca eski kural onu "ezme" sayip bir sonraki
--  uretimde basligin GUNCEL carpanini gormezden gelirdi (iz kendi kendini
--  kilitler). Artik taban_liste_id/carpan/yuvarlama ezmeleri yalniz
--  yazim = 1 (Manuel) satirda okunur; hesap satiri HEP basligin kuralina
--  uyar. Kullanici satirin carpanini elle degistirirse asagidaki tetik
--  satiri Manuel yapar ve fiyati taban_fiyat x yeni carpan'dan yeniden
--  hesaplar - boylece degistirilen carpan mesru ezmeye donusur ve "Listeyi
--  Uret" onu artik ezmez.
--
--  Tetik uretimin kendi update'ini kullanici duzenlemesinden uretim_tarihi
--  ile ayirir: uretim her yazista uretim_tarihi = now() gunceller, kart
--  duzenlemesi bu kolona hic dokunmaz (kartta yazilabilir degil).
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1) fn_fiyat_listesi_fiyat: donuse taban + carpan_kullanilan eklendi.
--    Donus tipi degistigi icin once DROP (create or replace tip degistiremez).
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
    -- 209: hesap dalinda carpan oncesi taban (KDV cevrimi sonrasi) ve
    --   kullanilan carpan; yazili satir dalinda satirdaki iz kolonlari.
    taban             numeric,
    carpan_kullanilan numeric)
language plpgsql stable
as $$
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
                                nullif(r.taban_fiyat, 0), r.carpan;
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
    --    carpan/taban uretim IZIdir, kural degildir - ezme sayilsaydi uretim
    --    kendi yazdigi carpani okuyup basligin guncel kuralini goremezdi.
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
             'hesap'::text,
             v_taban,
             v_carpan;
end $$;

comment on function public.fn_fiyat_listesi_fiyat(integer, integer, integer, integer, boolean) is
  'Kalemin liste fiyati. Once yazili satir; yoksa kural: taban liste (rekursif) '
  'ya da kok listede kart fiyati -> KDV cevir -> x carpan -> yuvarla. Satir kural '
  'ezmesi yalniz Manuel (yazim=1) satirda; taban/carpan_kullanilan hesap izidir (209).';

-- ---------------------------------------------------------------------------
-- 2) fn_fiyat_listesi_uret: taban_fiyat = carpan oncesi taban, carpan = iz.
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
        -- ZINCIRLI listede (taban_liste_id dolu) kalem TABANDA YAZILI DEGILSE
        --   ATLANIR (209, kullanici): fn kok listeye kadar inip kalemin KART
        --   fiyatina duser ve "TTB2018 = Puan x 7,0092" gibi bir listeye
        --   tabaninda olmayan 22 kalemi EUR-kur fiyatiyla eklerdi. Kok liste
        --   uretiminde kart fiyati meskrudur, zincirde degil.
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
             durum, yazim, taban_fiyat, carpan, uretim_tarihi, ekleyen, degistiren)
        values
            (p_liste_id, k.stok_id, k.hizmet_id, v_f.fiyat, v_f.doviz_cinsi, v_f.kdv_dahil,
             coalesce(k.birim, 0), 1, 2,
             coalesce(v_f.taban, v_f.fiyat), v_f.carpan_kullanilan,
             now()::timestamp, p_kullanici, p_kullanici)
        on conflict do nothing;

        if found then
            v_ekle := v_ekle + 1;
        else
            -- Var olan satir: yalniz HESAP satirlari guncellenir. carpan da
            --   guncel kuralin iziyle tazelenir (ezme degil - fn hesap
            --   satirinda ezme okumaz).
            update public.fiyat_listesi_satir
               set fiyat = v_f.fiyat, doviz_cinsi = v_f.doviz_cinsi, kdv_dahil = v_f.kdv_dahil,
                   taban_fiyat = coalesce(v_f.taban, v_f.fiyat),
                   carpan = v_f.carpan_kullanilan,
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
-- 3) Tetik: kullanici satirin carpanini degistirirse satir MANUEL olur ve
--    fiyat taban_fiyat x carpan'dan yeniden hesaplanir (taban_fiyat DEGISMEZ).
--    Uretimin update'i uretim_tarihi'ni degistirdigi icin tetigi atlar.
-- ---------------------------------------------------------------------------
create or replace function public.fn_sls_carpan_manuel()
returns trigger language plpgsql
as $$
begin
    if new.carpan is distinct from old.carpan
       and new.uretim_tarihi is not distinct from old.uretim_tarihi then
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

drop trigger if exists trg_sls_carpan_manuel on public.fiyat_listesi_satir;
create trigger trg_sls_carpan_manuel
    before update on public.fiyat_listesi_satir
    for each row execute function public.fn_sls_carpan_manuel();

-- ---------------------------------------------------------------------------
-- 4) Temizlik + iz duzeltme.
--    a) Zincirli listeye onceki uretimlerin ekledigi "tabaninda olmayan"
--       hesap satirlari silinir (kart fiyatina dusup uretilmislerdi).
--    b) Kalan HESAP satirlarinin taban/carpan izi tazelenir (yalniz
--       yazim = 2; Manuel satirlara dokunulmaz). Yeni satir EKLENMEZ.
-- ---------------------------------------------------------------------------
do $$
declare
    s       record;
    v       record;
    v_sil   integer;
    v_duz   integer := 0;
begin
    -- Alias "fs": DO bloqundaki `s` record degiskeniyle cakismasin (plpgsql
    --   SQL icindeki s.stok_id'yi degisken sanip "not assigned" hatasi verir).
    delete from public.fiyat_listesi_satir fs
     using public.fiyat_listesi fl
     where fl.id = fs.liste_id and fs.yazim = 2 and fl.taban_liste_id is not null
       and not exists (select 1 from public.fiyat_listesi_satir t
                        where t.liste_id = fl.taban_liste_id and t.durum = 1 and t.fiyat > 0
                          and (fs.stok_id   is not null and t.stok_id   = fs.stok_id
                            or fs.hizmet_id is not null and t.hizmet_id = fs.hizmet_id));
    get diagnostics v_sil = row_count;
    if v_sil > 0 then
        raise notice '209: zincirli listelerde tabaninda olmayan % hesap satiri silindi.', v_sil;
    end if;

    for s in select id, liste_id, stok_id, hizmet_id
               from public.fiyat_listesi_satir where yazim = 2
    loop
        select * into v
          from public.fn_fiyat_listesi_fiyat(s.liste_id, s.stok_id, s.hizmet_id, 0, false);
        if v.fiyat is null or v.fiyat <= 0 then continue; end if;

        update public.fiyat_listesi_satir
           set fiyat = v.fiyat, doviz_cinsi = v.doviz_cinsi, kdv_dahil = v.kdv_dahil,
               taban_fiyat = coalesce(v.taban, v.fiyat),
               carpan = v.carpan_kullanilan,
               uretim_tarihi = now()::timestamp
         where id = s.id;
        v_duz := v_duz + 1;
    end loop;

    raise notice '209 tamam: % hesap satirinin taban/carpan izi tazelendi; carpan degisimi tetigi kuruldu.', v_duz;
end $$;
