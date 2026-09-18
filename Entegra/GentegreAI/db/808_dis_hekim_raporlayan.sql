-- =====================================================================
-- 808 - DIS HEKIM "RAPORLAYAN" ROLUNDE DE PRIM ALABILIR
--
-- Kullanici: *"361'i dış radyolog Raporlayan alacak şekilde genişlet"*.
--
-- 361'DEKI KURALIN VARSAYIMI DEGISTI. O gun dis hekim, hastayi BIZE GONDEREN
-- taraftı: isi biz yapiyorduk, o yalnizca sevk ediyordu - "dis hekim yalniz
-- Gonderen rolunde prim alabilir" bu yuzden dogruydu. Teleradyoloji (797) bu
-- varsayimi bozdu: disaridan calisan radyolog ISI KENDISI YAPIYOR, raporu o
-- yaziyor. 807'de dis radyolog PAYSIZ kaliyordu ve fatura ekrani bunu uyari
-- olarak bildiriyordu.
--
-- KURAL SILINMIYOR, DARALTILIYOR: dis hekim hala her rolde prim alamaz -
-- yalnizca GONDEREN (1) ve RAPORLAYAN (5). "Uygulayan", "Anestezi",
-- "Teknisyen" gibi roller kurum icinde fiilen yapilan islerdir; disaridan
-- calisan biri onlari yapmaz ve o rollerde prim satiri gorunuyorsa bu
-- neredeyse her zaman yanlis kisi secilmesidir.
--
-- ROL SATIRI ARTIK GIRILEBILIR: dis hekimin Raporlayan olup olmadigi
-- BILINMELI (kimi sevk eder, kimi okur) - 369'daki "dis hekime rol satiri
-- girilemez" yasagi bu yuzden Raporlayan icin kalkiyor. Gonderen rolu eskisi
-- gibi ORTUK: "Primli" isaretli her dis hekim gonderen adayidir, ayrica
-- sorulmaz.
-- =====================================================================

-- ----------------------------------------------- belge satiri rol kurali ----
create or replace function public.tg_belge_satir_rol_dogrula()
returns trigger
language plpgsql
as $$
declare v_dis smallint;
begin
    select coalesce(p.dis_hekim, 0) into v_dis
      from public.taraf_personel p where p.id = new.taraf_id;

    -- 1 Gonderen · 5 Raporlayan: disaridan calisan hekim ya hastayi gonderir
    --   ya raporu yazar (teleradyoloji). Otekiler kurum icinde yapilan
    --   islerdir.
    if coalesce(v_dis, 0) = 1 and new.rol not in (1, 5) then
        raise exception
            'Dış hekim yalnız "Gönderen" ya da "Raporlayan" rolünde prim alabilir (taraf %).',
              new.taraf_id using errcode = 'GK422';
    end if;
    return new;
end $$;

comment on function public.tg_belge_satir_rol_dogrula() is
  '361/808: dis hekim yalniz Gonderen (sevk) ya da Raporlayan (teleradyoloji) '
  'rolunde prim alabilir.';

-- ------------------------------------------------- rol satiri girilebilir ----
create or replace function public.tg_taraf_prim_rol_dogrula()
returns trigger
language plpgsql
as $$
declare
    v_personel  smallint;
    v_dis       smallint;
begin
    select t.personel, coalesce(p.dis_hekim, 0)
      into v_personel, v_dis
      from public.taraf t
      left join public.taraf_personel p on p.id = t.id
     where t.id = new.taraf_id;

    if coalesce(v_personel, 0) <> 1 then
        raise exception 'Prim rolü yalnız personele / hekime verilir (taraf %).',
              new.taraf_id using errcode = 'GK422';
    end if;

    -- DIS HEKIMDE YALNIZ "RAPORLAYAN" SATIRI ANLAMLI (808): Gonderen rolu
    --   ortuktur ("Primli" isaretli her dis hekim gonderen adayidir), oteki
    --   roller disaridan calisan biri icin tanimli degildir.
    if v_dis = 1 and new.rol <> 5 then
        raise exception
            'Dış hekimde yalnız "Raporlayan" rolü ayrıca işaretlenir; "Gönderen" '
            'rolü kartındaki Çalışma Şekli "Primli" ile zaten gelir (taraf %).',
              new.taraf_id using errcode = 'GK422';
    end if;
    return new;
end $$;

comment on function public.tg_taraf_prim_rol_dogrula() is
  '362/369/808: prim rolu yalniz personele verilir; dis hekimde yalniz '
  '"Raporlayan" satiri girilir (Gonderen ortuk).';

-- ------------------------------------------------------------- adaylar ----
-- Dis hekim: "Primli" isaretliyse GONDEREN adayi (ortuk, eskisi gibi) ve
--   AYRICA taraf_prim_rol'de Raporlayan satiri varsa RAPORLAYAN adayi.
create or replace view public.v_prim_rol_aday as
select r.taraf_id                as id,
       t.unvan                   as ad,
       r.rol,
       r.varsayilan,
       0::smallint               as dis_mi,
       coalesce(t.departman, 0)  as bolum_id,
       coalesce(t.durum, 1)      as durum
  from public.taraf_prim_rol r
  join public.taraf t on t.id = r.taraf_id
  join public.taraf_personel p on p.id = r.taraf_id
 where coalesce(p.dis_hekim, 0) = 0
   and coalesce(p.calisma_sekli, 0) = 3
union all
select t.id, t.unvan,
       1::smallint               as rol,          -- Gönderen (örtük)
       1::smallint               as varsayilan,
       1::smallint               as dis_mi,
       coalesce(t.departman, 0), coalesce(t.durum, 1)
  from public.taraf t
  join public.taraf_personel p on p.id = t.id
 where p.dis_hekim = 1 and coalesce(p.calisma_sekli, 0) = 3
union all
-- TELERADYOLOJI (808): disaridan okuyan radyolog. Isaret ACIK - her dis
--   hekim rapor yazmaz; yazan, kartinda Raporlayan olarak isaretlenir.
select r.taraf_id, t.unvan,
       r.rol, r.varsayilan,
       1::smallint               as dis_mi,
       coalesce(t.departman, 0), coalesce(t.durum, 1)
  from public.taraf_prim_rol r
  join public.taraf t on t.id = r.taraf_id
  join public.taraf_personel p on p.id = r.taraf_id
 where p.dis_hekim = 1 and coalesce(p.calisma_sekli, 0) = 3
   and r.rol = 5;

comment on view public.v_prim_rol_aday is
  'Prim rol adaylari (361/362/367/369/808): isaret taraf_personel.calisma_sekli '
  '= 3 ("Primli"). Ic personelde taraf_prim_rol satiri hangi rollerde prim '
  'aldigini soyler. DIS HEKIM: "Gönderen" ORTUK; "Raporlayan" ise ayrica '
  'isaretlenir (teleradyolojide isi disaridan calisan radyolog yapar).';

-- --------------------------------------------- teleradyoloji pay dagitimi ----
-- 807'deki "dis radyologu atla" istisnasi KALKIYOR: artik payi yazilabiliyor.
create or replace function public.fn_telerad_fatura_rol(p_belge_id integer)
returns integer
language plpgsql
as $function$
declare
    v_satir     record;
    v_pay       record;
    v_sayac     integer := 0;
    v_hedef     numeric(7,2);   -- satirda dagitilacak TOPLAM pay
    v_dagitilan numeric(7,2);
    v_yuzde     numeric(7,2);
begin
    for v_satir in
        select bs.id,
               count(*)                                                   as is_sayisi,
               count(*) filter (where i.atanan_radyolog_id is not null)    as okunan,
               count(distinct i.atanan_radyolog_id)                        as radyolog_sayisi
          from public.belge_satir bs
          join public.telerad_istek i on i.fatura_satir_id = bs.id
         where bs.belge_id = p_belge_id
         group by bs.id
    loop
        -- ELLE GIRILMIS ROL DOKUNULMAZ (326 deseni).
        if exists (select 1 from public.belge_satir_rol e
                    where e.belge_satir_id = v_satir.id and e.rol = 5 and e.kaynak = 1)
        then
            continue;
        end if;

        delete from public.belge_satir_rol bsr
         where bsr.belge_satir_id = v_satir.id and bsr.rol = 5 and bsr.kaynak = 2;

        -- ATANMAMIS ISIN PAYI BOSTA KALIR: payda satirdaki TUM isler.
        v_hedef := round(100.0 * v_satir.okunan / nullif(v_satir.is_sayisi, 0), 2);
        v_dagitilan := 0;

        for v_pay in
            select i.atanan_radyolog_id as radyolog,
                   count(*)             as adet,
                   row_number() over (order by count(*) desc, i.atanan_radyolog_id) as sira
              from public.telerad_istek i
             where i.fatura_satir_id = v_satir.id
               and i.atanan_radyolog_id is not null
             group by i.atanan_radyolog_id
             order by count(*) desc, i.atanan_radyolog_id
        loop
            if v_pay.sira = v_satir.radyolog_sayisi then
                -- SON PAY ARTIGI ALIR: uc kisiye bolunen satirda
                --   33.33 x 3 = 99.99 kalirdi; kayip kurus birine yazilmali.
                v_yuzde := v_hedef - v_dagitilan;
            else
                v_yuzde := round(100.0 * v_pay.adet / nullif(v_satir.is_sayisi, 0), 2);
            end if;

            insert into public.belge_satir_rol
                   (belge_satir_id, rol, taraf_id, pay_yuzde, kaynak)
            values (v_satir.id, 5, v_pay.radyolog, v_yuzde, 2)
            on conflict (belge_satir_id, rol, taraf_id)
            do update set pay_yuzde = excluded.pay_yuzde;

            v_dagitilan := v_dagitilan + v_yuzde;
            v_sayac := v_sayac + 1;
        end loop;

        perform public.fn_prim_uret_belge(v_satir.id);
    end loop;

    return v_sayac;
end $function$;

comment on function public.fn_telerad_fatura_rol(integer) is
  '807/808: teleradyoloji donem faturasinin satirlarina RAPORLAYAN (rol 5) '
  'payini adede gore dagitir ve primi uretir. Dis radyolog da pay alir (808). '
  'Elle yazilmis rolu ezmez.';

do $$
declare v_sayi integer;
begin
    select count(*) into v_sayi
      from public.taraf_personel p
     where coalesce(p.dis_hekim, 0) = 1 and coalesce(p.calisma_sekli, 0) = 3;
    raise notice '808: "Primli" dis hekim sayisi % - Raporlayan isareti '
                 'personel kartindan verilir.', v_sayi;
end $$;
