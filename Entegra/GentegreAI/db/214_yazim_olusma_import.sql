-- ============================================================================
--  Gentegre AI — "YAZIM" -> "OLUSMA" + IMPORT DEGERI
--  214_yazim_olusma_import.sql
--
--  Kullanici istegi: kolon "Oluşma" diye okunmali ve Excel'den iceri alinan
--  satirlar Manuel degil IMPORT olarak isaretlenmeli (satirin NEREDEN
--  geldigi gorunsun): 1 = Manuel, 2 = Hesap, 3 = İmport.
--
--  Kurallar:
--   - "Listeyi Uret" yalniz HESAP (2) satirlarini gunceller - Import da
--     Manuel gibi KORUNUR (fn/uret'te yazili sayilir, fiyat > 0).
--   - Import satirda fiyat/carpan elle degisirse satir MANUEL olur (mevcut
--     tetik zaten yazim := 1 yazar); Olusma HESAP'a cevrilirse kuraldan
--     tazelenir (tetik dal 1 kosulu 1 -> 1,3 genisletildi).
--   - Satir kural ezmesi YALNIZ Manuel'de kalir - Import satir Excel'den
--     fiyat tasir, kural tasimaz.
-- ============================================================================

-- 1) Kod listesi: baslik + yeni deger.
update public.kod_liste set ad = 'Oluşma' where kod = 'fiyat_listesi.yazim';

insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
select l.id, 3, 'İmport', 30, 1
  from public.kod_liste l
 where l.kod = 'fiyat_listesi.yazim'
   and not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = 3);

-- 2) fn_fiyat_listesi_fiyat: kaynak etiketi 3 dalli (davranis ayni - Import
--    yazili satirdir, fiyat > 0 ile doner; ezme yalniz Manuel'de).
--    Imza/veri tipi degismiyor - create or replace yeter.
create or replace function public.fn_fiyat_listesi_fiyat(
    p_liste_id  integer,
    p_stok_id   integer default null,
    p_hizmet_id integer default null,
    p_derinlik  integer default 0,
    p_yazili    boolean default true,
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
    if p_derinlik > 20 then
        raise exception 'Fiyat listesi zinciri 20 adimi asti (liste %).', p_liste_id;
    end if;

    select * into l from public.fiyat_listesi where id = p_liste_id;
    if not found then return; end if;

    -- 1) Listede YAZILI satir (Manuel, Import ya da fiyatli Hesap)
    if p_yazili then
        select * into r from public.fiyat_listesi_satir
         where liste_id = p_liste_id and durum = 1
           and (p_stok_id   is not null and stok_id   = p_stok_id
             or p_hizmet_id is not null and hizmet_id = p_hizmet_id)
         limit 1;

        if found and (r.yazim in (1, 3) or r.fiyat > 0) then
            return query select r.fiyat, r.doviz_cinsi, r.kdv_dahil,
                                case r.yazim when 1 then 'satir-manuel'
                                             when 3 then 'satir-import'
                                             else 'satir-hesap' end,
                                nullif(r.taban_fiyat, 0), r.carpan, r.id;
            return;
        end if;
    else
        select * into r from public.fiyat_listesi_satir
         where liste_id = p_liste_id
           and (p_stok_id   is not null and stok_id   = p_stok_id
             or p_hizmet_id is not null and hizmet_id = p_hizmet_id)
         limit 1;
    end if;

    -- 2) Kural. Ezme YALNIZ Manuel satirda ve p_ezme aciksa (209/212);
    --    Import satir Excel fiyati tasir, kural tasimaz.
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
        select k.fiyat, k.doviz_cinsi, k.kdv_dahil
          into v_taban, v_doviz, v_tbn_kdv
          from public.fn_kalem_kart_fiyati(p_stok_id, p_hizmet_id, l.yon) k;
        v_tbn_sid := null;
    end if;

    if v_taban is null then return; end if;

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

-- 3) Uretimin "korunan" sayaci Import'u da sayar (uret zaten yalniz yazim=2
--    gunceller - Import satira dokunmaz).
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

        select * into v_f
          from public.fn_fiyat_listesi_fiyat(p_liste_id, k.stok_id, k.hizmet_id, 0, false);

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

-- 4) Tetik: Olusma HESAP'a cevrilince tazeleme artik Import'tan da calisir.
create or replace function public.fn_sls_carpan_manuel()
returns trigger language plpgsql
as $$
declare
    v record;
begin
    if new.uretim_tarihi is distinct from old.uretim_tarihi then
        return new;
    end if;

    -- 1) MANUEL/IMPORT -> HESAP: kuraldan tam tazeleme.
    if old.yazim in (1, 3) and new.yazim = 2 then
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

    -- 2) CARPAN degisti: Manuel + fiyat = taban_fiyat x carpan.
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
        return new;
    end if;

    -- 3) FIYAT elle degisti: Manuel + carpan geri hesabi (zincirli satirda).
    if new.fiyat is distinct from old.fiyat then
        new.yazim := 1;
        if new.taban_liste_id is not null
           and coalesce(new.taban_fiyat, 0) > 0 and coalesce(new.fiyat, 0) > 0 then
            new.carpan := round(new.fiyat / new.taban_fiyat, 6);
        end if;
    end if;
    return new;
end $$;

-- 5) Veri onarimi: Excel'den alinmis satirlar Import'a cevrilir. Hangi
--    listelerin iceri alma gordugu islem loglarindan (924, iceriAl) bulunur -
--    liste id'leri sabitlenmez, musteride de dogru calisir. O listelerdeki
--    Manuel satirlar import kaynaklidir (elle eklenen tek tuk satir da 3
--    olur - satir editlenirse tetik yine Manuel'e ceker, kayip yok).
do $$
declare
    v_duz integer;
begin
    update public.fiyat_listesi_satir fs
       set yazim = 3
     where fs.yazim = 1
       and fs.liste_id in (select distinct kayit_id::integer
                             from public.islem_log
                            where tablo_id = 924 and bilgi ? 'iceriAl');
    get diagnostics v_duz = row_count;
    raise notice '214 tamam: Olusma listesi + İmport degeri; % iceri-alinmis satir İmport''a cevrildi.', v_duz;
end $$;
