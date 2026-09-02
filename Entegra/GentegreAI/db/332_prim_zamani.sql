-- 332: PRİM ZAMANI - "faturalamada mı, tahsilatta mı" plan seçeneği.
--
-- Kullanıcı: "faturalamada veya tahsilatta alır diye opsiyon olmalı."
--
-- Bugüne kadar prim YALNIZ tahsilattan doğuyordu (321/324). SGK gibi geç ve
-- kesintili ödeyen kurumlarda bu, hekimin primini aylarca geciktiriyor; buna
-- karşılık faturada prim vermek tahsil edilmeyen alacağın primini peşin
-- ödemek demek. Karar kurumun: artık PLAN BAŞINA seçiliyor.
--
--   1 TAHSİLATTA (varsayılan) : prim tahsilat dağıtımından doğar, tabanı
--     tahsil edilen tutarın KDV hariç karşılığı; kesinti olursa prim de
--     otomatik azalır.
--   2 FATURALAMADA           : kalem gelir belgesine (tahakkuk/fiş/fatura)
--     dönüştüğü an prim doğar, tabanı satırın (payına düşen) matrahı,
--     tarihi GELİR BELGESİNİN tarihi. Tahsilat beklenmez.
--
-- Aynı plan satırı iki yoldan birden prim üretmez - üretim yolu planın
-- zamanına bakar, öteki yol o kuralı atlar.

alter table public.prim_plani
  add column if not exists prim_zamani smallint not null default 1;

comment on column public.prim_plani.prim_zamani is
  'Prim ne zaman doğar (332): 1 tahsilatta · 2 faturalamada (gelir belgesinde).';

insert into public.kod_liste (kod, ad)
select 'prim.zaman', 'Prim Zamanı'
 where not exists (select 1 from public.kod_liste where kod = 'prim.zaman');

insert into public.kod_deger (liste_id, deger, ad)
select kl.id, v.deger, v.ad
  from (values (1, 'Tahsilatta'), (2, 'Faturalamada')) v(deger, ad)
  join public.kod_liste kl on kl.kod = 'prim.zaman'
 where not exists (select 1 from public.kod_deger d
                    where d.liste_id = kl.id and d.deger = v.deger);

-- Faturalama primi TAHSILATA bagli degildir: dagitim_id bostur. Ayni kalem +
--   kisi + rol + pay icin tek satir.
create unique index if not exists ux_hakedis_satir_belge
    on public.hakedis_satir (belge_satir_id, taraf_id, rol, pay)
 where dagitim_id is null;

-- ================================================= gelir belgesi bilgisi ===
-- Tur ve TARIH birlikte gerekiyor (faturalama priminin tarihi = belge
-- tarihi). Zincir okumasi tek yerde kalsin diye ortak fonksiyon.
create or replace function public.fn_prim_gelir_belgesi(
    p_satir_id integer, p_pay smallint default 0)
returns table (tur smallint, tarih date, belge_id integer)
language sql stable as $$
    with recursive zincir(satir_id, belge_id, tur, tarih, taraf_id, derinlik) as (
        select s.id, b.id, b.tur, b.belge_tarihi::date, b.taraf_id, 0
          from public.belge_satir s
          join public.belge b on b.id = s.belge_id
         where s.id = p_satir_id
        union all
        select h.id, b2.id, b2.tur, b2.belge_tarihi::date, b2.taraf_id, z.derinlik + 1
          from zincir z
          join public.belge_satir h on h.kaynak_tur = 30 and h.kaynak_id = z.satir_id
          join public.belge b2 on b2.id = h.belge_id
         where z.derinlik < 5
    ),
    kurum as (
        select bb.odeyen_kurum_id
          from public.belge_satir s
          join public.belge_basvuru bb on bb.id = s.belge_id
         where s.id = p_satir_id and bb.odeyen_kurum_id is not null
    ),
    paya_uygun as (
        select z.tur, z.tarih, z.belge_id
          from zincir z cross join kurum k
         where z.derinlik > 0
           and ((p_pay = 2 and z.taraf_id = k.odeyen_kurum_id)
             or (p_pay = 1 and z.taraf_id is distinct from k.odeyen_kurum_id))
         order by z.derinlik desc, z.satir_id desc limit 1
    ),
    genel as (
        -- Paylasim YOKSA zincirin son halkasi gelir belgesidir.
        select z.tur, z.tarih, z.belge_id from zincir z
         where not exists (select 1 from kurum)
         order by z.derinlik desc, z.satir_id desc limit 1
    ),
    kaynak as (
        select z.tur, z.tarih, z.belge_id from zincir z where z.derinlik = 0
    )
    -- Paylasimli satirda PAYA UYGUN dal yoksa o pay henuz BELGELENMEMISTIR:
    --   kaynagin kendi turu (siparis/basvuru) doner ve cagiran tarafta
    --   "taslak" sayilir. Oteki payin belgesi bu paya mal edilmez.
    select coalesce(p.tur, g.tur, k.tur)::smallint,
           coalesce(p.tarih, g.tarih, k.tarih),
           coalesce(p.belge_id, g.belge_id, k.belge_id)
      from kaynak k
      left join paya_uygun p on true
      left join genel g on true;
$$;

comment on function public.fn_prim_gelir_belgesi is
  'Kalemin gelir belgesi (332): tur + tarih + belge, paya uygun dal.';

-- Belge TURU ayni zincirden okunur - iki ayri zincir mantigi tutulmaz.
create or replace function public.fn_prim_belge_turu(
    p_satir_id integer, p_pay smallint default 0)
returns smallint language sql stable as $$
    select tur from public.fn_prim_gelir_belgesi(p_satir_id, p_pay);
$$;

-- ============================================== eslestirme: zaman doner ====
drop function if exists public.fn_prim_plan_satiri(
    smallint, integer, integer, integer, smallint, smallint, integer, integer,
    date, smallint);

create or replace function public.fn_prim_plan_satiri(
    p_rol           smallint,
    p_taraf_id      integer,
    p_hizmet_id     integer,
    p_stok_id       integer,
    p_belge_tur     smallint,
    p_pay           smallint,
    p_kurum_id      integer,
    p_sube_id       integer,
    p_tarih         date,
    p_tahsilat_turu smallint default 0)
returns table (plan_id integer, satir_id integer, oran_tipi smallint,
               deger numeric, alt_sinir numeric, ust_sinir numeric, baz smallint,
               prim_zamani smallint)
language sql stable as $$
    select p.id, s.id, s.oran_tipi, s.deger, s.alt_sinir, s.ust_sinir, p.baz,
           coalesce(p.prim_zamani, 1)
      from public.prim_plani p
      join public.prim_plani_satir s on s.plan_id = p.id
     where coalesce(p.durum, 1) = 1
       and p.baslangic <= p_tarih
       and (p.bitis is null or p.bitis >= p_tarih)
       and s.rol = p_rol
       and (p.hekim_id is null or p.hekim_id = p_taraf_id)
       and (coalesce(p.odeyen_kurum_id, 0) = 0 or p.odeyen_kurum_id = p_kurum_id)
       and (coalesce(p.sube_id, 0) = 0 or p.sube_id = p_sube_id)
       and (s.tip = 1
            or (s.tip = 2 and (
                   (coalesce(s.kalem_turu, 0) in (0, 2)
                    and s.hedef_id = (select h.kategori from public.hizmet h
                                       where h.id = p_hizmet_id))
                or (coalesce(s.kalem_turu, 0) in (0, 1)
                    and s.hedef_id = (select st.kategori from public.stok st
                                       where st.id = p_stok_id))))
            or (s.tip = 3 and (
                   (coalesce(s.kalem_turu, 0) in (0, 2) and s.hedef_id = p_hizmet_id)
                or (coalesce(s.kalem_turu, 0) in (0, 1) and s.hedef_id = p_stok_id))))
       and (s.belge_turleri = ''
            or p_belge_tur is null
            or p_belge_tur::text = any(string_to_array(s.belge_turleri, ',')))
       -- Tahsilat turu kriteri YALNIZ tahsilat zamanli planda anlamlidir:
       --   faturalama priminde henuz odeme araci bilinmez.
       and (coalesce(s.tahsilat_turu, 0) = 0
            or coalesce(p.prim_zamani, 1) = 2
            or s.tahsilat_turu = p_tahsilat_turu)
       and (s.pay = 0 or s.pay = p_pay)
     order by
       (case s.tip when 3 then 3 when 2 then 1 else 0 end)
       + (case when coalesce(s.kalem_turu, 0) <> 0 then 1 else 0 end)
       + (case when s.belge_turleri <> '' then 1 else 0 end)
       + (case when coalesce(s.tahsilat_turu, 0) <> 0 then 1 else 0 end)
       + (case when s.pay <> 0 then 1 else 0 end)
       + (case when p.hekim_id is not null then 1 else 0 end)
       + (case when coalesce(p.odeyen_kurum_id, 0) <> 0 then 1 else 0 end) desc,
       p.oncelik desc, s.sira, s.id
     limit 1;
$$;

comment on function public.fn_prim_plan_satiri is
  'Kalem+rol icin EN DAR eslesen prim plan satiri (324/328/330/332).';

-- ================================================ tahsilat yolu (zamanli) ==
create or replace function public.fn_prim_uret(p_dagitim_id integer)
returns integer language plpgsql as $$
declare
  d          record;
  r          record;
  kural      record;
  v_matrah   numeric(19,4);
  v_tutar    numeric(19,4);
  v_belgetur smallint;
  v_durum    smallint;
  v_kurum    integer;
  v_sube     integer;
  v_tarih    date;
  v_sayac    integer := 0;
begin
    select d2.id, d2.belge_satir_id, d2.pay, d2.tutar,
           k.islem_tarihi::date as tarih, k.durum, k.iptal_islem_id,
           k.tur as tahsilat_turu,
           s.hizmet_id, s.stok_id, s.kdv, b.sube_id, bb.odeyen_kurum_id
      into d
      from public.kasa_islem_dagitim d2
      join public.kasa_islem k on k.id = d2.kasa_islem_id
      join public.belge_satir s on s.id = d2.belge_satir_id
      join public.belge b on b.id = s.belge_id
      left join public.belge_basvuru bb on bb.id = b.id
     where d2.id = p_dagitim_id;

    if not found then return 0; end if;

    delete from public.hakedis_satir
     where dagitim_id = p_dagitim_id and durum in (1, 2);

    if coalesce(d.durum, 0) <> 2 or d.iptal_islem_id is not null then
        return 0;
    end if;

    v_matrah := round(d.tutar / (1 + coalesce(d.kdv, 0) / 100.0), 4);
    v_belgetur := public.fn_prim_belge_turu(d.belge_satir_id, d.pay);
    v_durum := case when public.fn_prim_taslak_mi(v_belgetur) then 1 else 2 end;
    v_kurum := d.odeyen_kurum_id;
    v_sube := d.sube_id;
    v_tarih := d.tarih;

    for r in select br.rol, br.taraf_id, br.pay_yuzde
               from public.belge_satir_rol br
              where br.belge_satir_id = d.belge_satir_id
    loop
        select * into kural
          from public.fn_prim_plan_satiri(r.rol, r.taraf_id, d.hizmet_id, d.stok_id,
                                          v_belgetur, d.pay, v_kurum, v_sube, v_tarih,
                                          d.tahsilat_turu);
        if not found then continue; end if;
        -- FATURALAMA zamanli plan tahsilattan prim URETMEZ (332).
        if kural.prim_zamani = 2 then continue; end if;

        v_tutar := case when kural.oran_tipi = 2
                        then kural.deger
                        else round(v_matrah * kural.deger / 100.0, 2) end;
        v_tutar := round(v_tutar * coalesce(r.pay_yuzde, 100) / 100.0, 2);

        if kural.alt_sinir is not null and v_tutar < kural.alt_sinir then
            v_tutar := kural.alt_sinir;
        end if;
        if kural.ust_sinir is not null and v_tutar > kural.ust_sinir then
            v_tutar := kural.ust_sinir;
        end if;
        if v_tutar <= 0 then continue; end if;

        insert into public.hakedis_satir
               (taraf_id, rol, dagitim_id, belge_satir_id, plan_id, plan_satir_id,
                tarih, belge_tur, pay, taban, oran_tipi, deger, pay_yuzde, tutar, durum)
        values (r.taraf_id, r.rol, p_dagitim_id, d.belge_satir_id,
                kural.plan_id, kural.satir_id, v_tarih, v_belgetur, d.pay,
                v_matrah, kural.oran_tipi, kural.deger,
                coalesce(r.pay_yuzde, 100), v_tutar, v_durum)
        on conflict (dagitim_id, taraf_id, rol) where dagitim_id is not null
        do update set tutar = excluded.tutar, taban = excluded.taban,
                      deger = excluded.deger, belge_tur = excluded.belge_tur,
                      plan_id = excluded.plan_id, plan_satir_id = excluded.plan_satir_id,
                      durum = excluded.durum
        where hakedis_satir.durum in (1, 2);

        v_sayac := v_sayac + 1;
    end loop;

    return v_sayac;
end $$;

-- =============================================== faturalama yolu (yeni) ====
-- Kalem gelir belgesine dönüştüğünde prim üretir. Tahsilat BEKLENMEZ; taban
-- satırın (payına düşen) KDV hariç tutarı, tarih gelir belgesinin tarihidir.
create or replace function public.fn_prim_uret_belge(p_belge_satir_id integer)
returns integer language plpgsql as $$
declare
  s          record;
  gb         record;
  r          record;
  kural      record;
  v_pay      smallint;
  v_matrah   numeric(19,4);
  v_tutar    numeric(19,4);
  v_sayac    integer := 0;
  v_paylar   smallint[];
begin
    select bs.id, bs.hizmet_id, bs.stok_id, bs.kdv, bs.tutar,
           bs.hasta_tutar, bs.kurum_tutar,
           b.sube_id, b.durum as belge_durum, bb.odeyen_kurum_id
      into s
      from public.belge_satir bs
      join public.belge b on b.id = bs.belge_id
      left join public.belge_basvuru bb on bb.id = b.id
     where bs.id = p_belge_satir_id;

    if not found then return 0; end if;

    -- Yeniden uretilebilir FATURALAMA satirlarini temizle (onayli/odenmise
    --   dokunulmaz; tahsilat yolu satirlari dagitim_id ile ayrilir).
    delete from public.hakedis_satir
     where belge_satir_id = p_belge_satir_id and dagitim_id is null
       and durum in (1, 2);

    -- Paylasimli satirda hasta ve kurum payi AYRI prim uretir; paylasim
    --   yoksa tek satir (pay 0).
    if coalesce(s.hasta_tutar, 0) > 0 or coalesce(s.kurum_tutar, 0) > 0 then
        v_paylar := array[1, 2]::smallint[];
    else
        v_paylar := array[0]::smallint[];
    end if;

    foreach v_pay in array v_paylar
    loop
        v_matrah := case v_pay when 1 then coalesce(s.hasta_tutar, 0)
                               when 2 then coalesce(s.kurum_tutar, 0)
                               else coalesce(s.tutar, 0) end;
        if v_matrah <= 0 then continue; end if;

        select * into gb from public.fn_prim_gelir_belgesi(p_belge_satir_id, v_pay);
        -- Gelir belgesi YOKSA (kalem hala siparis/basvuru) faturalama primi
        --   dogmaz - "faturalandi" sayilmaz.
        if not found or public.fn_prim_taslak_mi(gb.tur) then continue; end if;

        for r in select br.rol, br.taraf_id, br.pay_yuzde
                   from public.belge_satir_rol br
                  where br.belge_satir_id = p_belge_satir_id
        loop
            select * into kural
              from public.fn_prim_plan_satiri(r.rol, r.taraf_id, s.hizmet_id, s.stok_id,
                                              gb.tur, v_pay, s.odeyen_kurum_id,
                                              s.sube_id, gb.tarih, 0::smallint);
            if not found then continue; end if;
            -- TAHSILAT zamanli plan faturadan prim uretmez (332).
            if coalesce(kural.prim_zamani, 1) <> 2 then continue; end if;

            v_tutar := case when kural.oran_tipi = 2
                            then kural.deger
                            else round(v_matrah * kural.deger / 100.0, 2) end;
            v_tutar := round(v_tutar * coalesce(r.pay_yuzde, 100) / 100.0, 2);

            if kural.alt_sinir is not null and v_tutar < kural.alt_sinir then
                v_tutar := kural.alt_sinir;
            end if;
            if kural.ust_sinir is not null and v_tutar > kural.ust_sinir then
                v_tutar := kural.ust_sinir;
            end if;
            if v_tutar <= 0 then continue; end if;

            insert into public.hakedis_satir
                   (taraf_id, rol, dagitim_id, belge_satir_id, plan_id, plan_satir_id,
                    tarih, belge_tur, pay, taban, oran_tipi, deger, pay_yuzde,
                    tutar, durum)
            values (r.taraf_id, r.rol, null, p_belge_satir_id,
                    kural.plan_id, kural.satir_id, gb.tarih, gb.tur, v_pay,
                    v_matrah, kural.oran_tipi, kural.deger,
                    coalesce(r.pay_yuzde, 100), v_tutar, 2)
            on conflict (belge_satir_id, taraf_id, rol, pay) where dagitim_id is null
            do update set tutar = excluded.tutar, taban = excluded.taban,
                          deger = excluded.deger, belge_tur = excluded.belge_tur,
                          tarih = excluded.tarih,
                          plan_id = excluded.plan_id,
                          plan_satir_id = excluded.plan_satir_id
            where hakedis_satir.durum in (1, 2);

            v_sayac := v_sayac + 1;
        end loop;
    end loop;

    return v_sayac;
end $$;

comment on function public.fn_prim_uret_belge is
  'Faturalama zamanli primi kalem gelir belgesine donusunce uretir (332).';

-- ----------------------------------------------------------- tetikler -----
-- Donusum: kaynak kalemin HEM tahsilat HEM faturalama primleri tazelenir.
create or replace function public.tg_prim_donusum()
returns trigger language plpgsql as $$
declare r record;
begin
    if coalesce(new.kaynak_tur, 0) <> 30 or coalesce(new.kaynak_id, 0) = 0 then
        return null;
    end if;
    for r in select d.id from public.kasa_islem_dagitim d
              where d.belge_satir_id = new.kaynak_id
    loop
        perform public.fn_prim_uret(r.id);
    end loop;
    perform public.fn_prim_uret_belge(new.kaynak_id);
    return null;
end $$;

-- Belge turu degisince: hem bu belgenin kalemleri hem kaynak kalemler.
create or replace function public.tg_prim_belge_tur()
returns trigger language plpgsql as $$
declare r record; r2 record;
begin
    if new.tur is not distinct from old.tur then return null; end if;

    for r in select d.id
               from public.kasa_islem_dagitim d
               join public.belge_satir s on s.id = d.belge_satir_id
              where s.belge_id = new.id
    loop
        perform public.fn_prim_uret(r.id);
    end loop;

    for r in select h.kaynak_id as satir_id
               from public.belge_satir h
              where h.belge_id = new.id and h.kaynak_tur = 30
                and h.kaynak_id is not null
    loop
        perform public.fn_prim_uret_belge(r.satir_id);
        for r2 in select d.id from public.kasa_islem_dagitim d
                   where d.belge_satir_id = r.satir_id
        loop
            perform public.fn_prim_uret(r2.id);
        end loop;
    end loop;
    return null;
end $$;

-- Donusum satiri SILINIRSE (fatura iptal/geri alma) faturalama primi de
--   dusmeli: kalem yeniden "faturalanmamis" olur.
create or replace function public.tg_prim_donusum_sil()
returns trigger language plpgsql as $$
begin
    if coalesce(old.kaynak_tur, 0) = 30 and coalesce(old.kaynak_id, 0) <> 0 then
        perform public.fn_prim_uret_belge(old.kaynak_id);
    end if;
    return null;
end $$;

drop trigger if exists tr_prim_donusum_sil on public.belge_satir;
create trigger tr_prim_donusum_sil
  after delete on public.belge_satir
  for each row execute function public.tg_prim_donusum_sil();

-- Radyoloji rol tetigi (326) faturalama yolunu da tazelesin.
create or replace function public.fn_rad_rol_tazele(p_istem_id integer)
returns integer language plpgsql as $$
declare
  v_satir  integer;
  v_hedef  jsonb;
  v_sayac  integer := 0;
  r        record;
begin
    select i.belge_satir_id into v_satir
      from public.radyoloji_istem i where i.id = p_istem_id;

    if coalesce(v_satir, 0) = 0 then return 0; end if;

    select coalesce(jsonb_agg(jsonb_build_object('rol', h.rol, 'taraf', h.taraf_id)),
                    '[]'::jsonb)
      into v_hedef
      from (
        select case when exists (select 1 from public.taraf_personel p
                                  where p.id = i.istek_hekim_id and p.dis_hekim = 1)
                    then 1 else 2 end   as rol,
               i.istek_hekim_id         as taraf_id
          from public.radyoloji_istem i
         where i.id = p_istem_id and i.istek_hekim_id is not null
        union all
        select 1, i.istek_kurum_id
          from public.radyoloji_istem i
         where i.id = p_istem_id and i.istek_hekim_id is null
           and i.istek_kurum_id is not null
        union all
        select 9, i.tekniker_id
          from public.radyoloji_istem i
         where i.id = p_istem_id and i.tekniker_id is not null
        union all
        select 5, rp.yazan_id
          from public.radyoloji_rapor rp
         where rp.istem_id = p_istem_id and rp.ust_rapor_id is null
           and rp.yazan_id is not null
        union all
        select 6, rp.onaylayan_id
          from public.radyoloji_rapor rp
         where rp.istem_id = p_istem_id and rp.ust_rapor_id is null
           and rp.onaylayan_id is not null
      ) h;

    delete from public.belge_satir_rol bsr
     where bsr.belge_satir_id = v_satir
       and bsr.kaynak = 2
       and not exists (select 1
                         from jsonb_to_recordset(v_hedef) as x(rol smallint, taraf integer)
                        where x.rol = bsr.rol and x.taraf = bsr.taraf_id)
       and not exists (select 1 from public.belge_satir_rol e
                        where e.belge_satir_id = v_satir and e.rol = bsr.rol
                          and e.kaynak = 1);

    insert into public.belge_satir_rol (belge_satir_id, rol, taraf_id, pay_yuzde, kaynak)
    select v_satir, x.rol, x.taraf, 100, 2
      from jsonb_to_recordset(v_hedef) as x(rol smallint, taraf integer)
     where not exists (select 1 from public.belge_satir_rol e
                        where e.belge_satir_id = v_satir and e.rol = x.rol
                          and e.kaynak = 1)
    on conflict (belge_satir_id, rol, taraf_id) do nothing;

    get diagnostics v_sayac = row_count;

    for r in select d.id from public.kasa_islem_dagitim d
              where d.belge_satir_id = v_satir
    loop
        perform public.fn_prim_uret(r.id);
    end loop;
    -- 332: faturalama zamanli primler de rol degisiminden etkilenir.
    perform public.fn_prim_uret_belge(v_satir);

    return v_sayac;
end $$;

-- ------------------------------------------------------------ görünüm -----
-- Hakediş satırında primin NEREDEN doğduğu görünsün: tahsilat mı, faturalama mı.
drop view if exists public.v_hakedis_satir;
create view public.v_hakedis_satir as
select hs.id,
       hs.hakedis_id,
       hs.taraf_id,
       coalesce(t.unvan, '')                  as kisi,
       hs.rol,
       coalesce(kr.ad, '')                    as rol_adi,
       hs.tarih,
       hs.belge_tur,
       coalesce(bt.ad, '')                    as belge_tur_adi,
       k.tur                                  as tahsilat_turu,
       coalesce(tt.ad, '')                    as tahsilat_turu_adi,
       case when hs.dagitim_id is null then 2 else 1 end as kaynak_tur,
       case when hs.dagitim_id is null then 'Faturalama' else 'Tahsilat' end as kaynak_adi,
       hs.pay,
       case hs.pay when 2 then 'Kurum payı' when 1 then 'Hasta payı' else 'Tümü' end as pay_adi,
       hs.taban,
       hs.oran_tipi,
       hs.deger,
       hs.pay_yuzde,
       hs.tutar,
       hs.durum,
       case hs.durum when 1 then 'Taslak' when 2 then 'Kesin'
                     when 3 then 'Onaylı'  when 4 then 'Ödendi'
                     else '' end              as durum_adi,
       hs.belge_satir_id,
       s.belge_id,
       coalesce(hz.ad, st.ad, s.aciklama, '') as kalem,
       coalesce(h2.unvan, '')                 as hasta,
       b.sube_id
  from public.hakedis_satir hs
  left join public.taraf t on t.id = hs.taraf_id
  join public.belge_satir s on s.id = hs.belge_satir_id
  join public.belge b on b.id = s.belge_id
  left join public.kasa_islem_dagitim d on d.id = hs.dagitim_id
  left join public.kasa_islem k on k.id = d.kasa_islem_id
  left join public.kasa_islem_turu tt on tt.kod = k.tur
  left join public.kasa_islem_turu bt on bt.kod = hs.belge_tur
  left join public.taraf h2 on h2.id = b.taraf_id
  left join public.hizmet hz on hz.id = s.hizmet_id
  left join public.stok st on st.id = s.stok_id
  left join public.kod_liste kl on kl.kod = 'prim.rol'
  left join public.kod_deger kr on kr.liste_id = kl.id and kr.deger = hs.rol
 where hs.durum <> 0;

comment on view public.v_hakedis_satir is
  'Hakediş satırı raporu (324/330/332): kaynak (tahsilat/faturalama) dahil.';
