-- 328: PRİM PLAN SATIRINDA KAPSAM = KAMPANYA SATIRIYLA AYNI DESEN.
--
-- Kullanıcı: "kampanya gibi yapmalısın: Hedef Türü yerine Tipi (seçilebilir),
-- sağında Stok/Hizmet kolonu, sağında Kapsam. Tipi Liste ise Kapsam 'Tüm
-- Liste', Kategori ise combo ile kategori seçilir (hizmet/stok seçimine göre),
-- Ürün ise jenerik arama ekranından ürün seçilir. Hizmet/kategori/modalite
-- kolonları iptal, üçü yerine Kapsam gelir."
--
-- 327'de hedef üç ayrı kolona bölünmüştü; kampanya kartında AYNI iş zaten
-- (tip, kalem_turu, kapsam) üçlüsüyle çözülmüş durumda. İki farklı desen
-- öğrenmek yerine kampanyanınki alındı - kullanıcı aynı ekranı iki yerde
-- tanıyor, kod da tek desene indi (GenDetayTablo'daki hücre çizimi ortak).
--
-- Kolonlar:
--   tip        kampanya.satir_tip  1 Liste (tümü) · 2 Kategori · 3 Ürün
--   kalem_turu kampanya.kalem_turu 0 Farketmez · 1 Stok · 2 Hizmet
--   hedef_id   kapsam: tip 2'de kategori id, tip 3'te stok/hizmet id
--
-- MODALİTE hedefi kalktı (kullanıcı kararı): radyolojide modalite başına
-- oran isteniyorsa o modalitenin tetkikleri bir KATEGORİ altında toplanır.

alter table public.prim_plani_satir
  add column if not exists tip        smallint not null default 1,
  add column if not exists kalem_turu smallint not null default 0,
  add column if not exists hedef_id   integer;

do $$
declare v_modalite integer := 0;
begin
    if exists (select 1 from information_schema.columns
                where table_schema = 'public' and table_name = 'prim_plani_satir'
                  and column_name = 'hedef_hizmet_id') then

        -- Hizmet hedefi -> Urun / Hizmet
        update public.prim_plani_satir
           set tip = 3, kalem_turu = 2, hedef_id = hedef_hizmet_id
         where hedef_hizmet_id is not null;

        -- Kategori hedefi -> Kategori (kalem turu: hizmet, prim hizmet uzerinden
        --   isliyordu; stok primi kullanan kurulumda satir elle duzeltilir).
        update public.prim_plani_satir
           set tip = 2, kalem_turu = 2, hedef_id = hedef_kategori_id
         where hedef_kategori_id is not null;

        -- MODALITE hedefi kalkti: satir "tumu"ne duser ama SESSIZ olmaz -
        --   aciklamaya not dusulur, yoksa oran farkinda olmadan genisler.
        select count(*) into v_modalite from public.prim_plani_satir
         where hedef_modalite is not null;
        if v_modalite > 0 then
            update public.prim_plani_satir
               set tip = 1, kalem_turu = 0, hedef_id = null,
                   aciklama = left(trim(both ' ' from
                       coalesce(aciklama, '') || ' [328: modalite hedefi kaldırıldı - '
                       || 'kapsamı kategori ile daraltın]'), 200)
             where hedef_modalite is not null;
            raise notice '328: % satirda modalite hedefi kaldirildi.', v_modalite;
        end if;

        alter table public.prim_plani_satir drop column hedef_tur;
        alter table public.prim_plani_satir drop column hedef_hizmet_id;
        alter table public.prim_plani_satir drop column hedef_kategori_id;
        alter table public.prim_plani_satir drop column hedef_modalite;
    end if;
end $$;

comment on column public.prim_plani_satir.tip is
  'Kapsam tipi (328): 1 Liste (tümü) · 2 Kategori · 3 Ürün - kampanya.satir_tip.';
comment on column public.prim_plani_satir.kalem_turu is
  'Kapsam kalem türü (328): 0 farketmez · 1 stok · 2 hizmet - kampanya.kalem_turu.';
comment on column public.prim_plani_satir.hedef_id is
  'Kapsam (328): tip 2''de kategori id, tip 3''te stok/hizmet id, tip 1''de bos.';

-- Tip ile kapsamin tutarliligi: Kategori/Urun satirinda kapsam SECILMELI,
--   Liste satirinda kapsam OLMAMALI. Yoksa "kategori" secilip bos birakilan
--   satir sessizce TUM kalemlere prim yazardi.
create or replace function public.tg_prim_kapsam()
returns trigger language plpgsql as $$
begin
    if new.tip in (2, 3) and coalesce(new.hedef_id, 0) = 0 then
        raise exception 'Kapsam seçilmeli: tip Kategori ya da Ürün ise kapsam boş bırakılamaz.'
            using errcode = 'GK422';
    end if;
    if new.tip = 1 then
        new.hedef_id := null;
    end if;
    return new;
end $$;

drop trigger if exists tr_prim_hedef_tek on public.prim_plani_satir;
drop function if exists public.tg_prim_hedef_tek();

drop trigger if exists tr_prim_kapsam on public.prim_plani_satir;
create trigger tr_prim_kapsam
  before insert or update on public.prim_plani_satir
  for each row execute function public.tg_prim_kapsam();

-- ------------------------------------------------- eslestirme fonksiyonu --
-- Imza degisti: modalite parametresi yerine STOK ID geliyor - kapsam artik
-- kalem turune (stok/hizmet) gore eslesiyor.
drop function if exists public.fn_prim_plan_satiri(
    smallint, integer, integer, smallint, smallint, smallint, integer, integer, date);

create or replace function public.fn_prim_plan_satiri(
    p_rol        smallint,
    p_taraf_id   integer,
    p_hizmet_id  integer,
    p_stok_id    integer,
    p_belge_tur  smallint,
    p_pay        smallint,
    p_kurum_id   integer,
    p_sube_id    integer,
    p_tarih      date)
returns table (plan_id integer, satir_id integer, oran_tipi smallint,
               deger numeric, alt_sinir numeric, ust_sinir numeric, baz smallint)
language sql stable as $$
    select p.id, s.id, s.oran_tipi, s.deger, s.alt_sinir, s.ust_sinir, p.baz
      from public.prim_plani p
      join public.prim_plani_satir s on s.plan_id = p.id
     where coalesce(p.durum, 1) = 1
       and p.baslangic <= p_tarih
       and (p.bitis is null or p.bitis >= p_tarih)
       and s.rol = p_rol
       -- kapsam (plan basligi)
       and (p.hekim_id is null or p.hekim_id = p_taraf_id)
       and (coalesce(p.odeyen_kurum_id, 0) = 0 or p.odeyen_kurum_id = p_kurum_id)
       and (coalesce(p.sube_id, 0) = 0 or p.sube_id = p_sube_id)
       -- kapsam (satir): Liste = tumu · Kategori · Urun
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
       -- belge türü kriteri (bos = tumu)
       and (s.belge_turleri = ''
            or p_belge_tur is null
            or p_belge_tur::text = any(string_to_array(s.belge_turleri, ',')))
       -- pay kriteri
       and (s.pay = 0 or s.pay = p_pay)
     order by
       -- ozgulluk: dar kapsam once
       (case s.tip when 3 then 3 when 2 then 1 else 0 end)
       + (case when coalesce(s.kalem_turu, 0) <> 0 then 1 else 0 end)
       + (case when s.belge_turleri <> '' then 1 else 0 end)
       + (case when s.pay <> 0 then 1 else 0 end)
       + (case when p.hekim_id is not null then 1 else 0 end)
       + (case when coalesce(p.odeyen_kurum_id, 0) <> 0 then 1 else 0 end) desc,
       p.oncelik desc, s.sira, s.id
     limit 1;
$$;

comment on function public.fn_prim_plan_satiri is
  'Kalem+rol icin EN DAR eslesen prim plan satiri (324; kapsam deseni 328).';

-- ------------------------------------------------------------ fn_prim_uret
-- Kalemin STOK kimligi de gerekiyor: kapsam stok kategorisi/urunu olabilir.
create or replace function public.fn_prim_uret(p_dagitim_id integer)
returns integer language plpgsql as $$
declare
  d          record;
  r          record;
  kural      record;
  v_matrah   numeric(19,4);
  v_tutar    numeric(19,4);
  v_belgetur smallint;
  v_kurum    integer;
  v_sube     integer;
  v_tarih    date;
  v_sayac    integer := 0;
begin
    select d2.id, d2.belge_satir_id, d2.pay, d2.tutar,
           k.islem_tarihi::date as tarih, k.durum, k.iptal_islem_id,
           s.hizmet_id, s.stok_id, s.kdv, b.sube_id, bb.odeyen_kurum_id
      into d
      from public.kasa_islem_dagitim d2
      join public.kasa_islem k on k.id = d2.kasa_islem_id
      join public.belge_satir s on s.id = d2.belge_satir_id
      join public.belge b on b.id = s.belge_id
      left join public.belge_basvuru bb on bb.id = b.id
     where d2.id = p_dagitim_id;

    if not found then return 0; end if;

    -- Taslak satirlari temizle (kesinlesmislere dokunma).
    delete from public.hakedis_satir
     where dagitim_id = p_dagitim_id and durum = 1;

    -- Iptal edilmis ya da gerceklesmemis tahsilat prim uretmez.
    if coalesce(d.durum, 0) <> 2 or d.iptal_islem_id is not null then
        return 0;
    end if;

    -- PRIM TABANI: dagitilan tutarin KDV'siz karsiligi (323 karari).
    v_matrah := round(d.tutar / (1 + coalesce(d.kdv, 0) / 100.0), 4);
    v_belgetur := public.fn_prim_belge_turu(d.belge_satir_id);
    v_kurum := d.odeyen_kurum_id;
    v_sube := d.sube_id;
    v_tarih := d.tarih;

    for r in select br.rol, br.taraf_id, br.pay_yuzde
               from public.belge_satir_rol br
              where br.belge_satir_id = d.belge_satir_id
    loop
        select * into kural
          from public.fn_prim_plan_satiri(r.rol, r.taraf_id, d.hizmet_id, d.stok_id,
                                          v_belgetur, d.pay, v_kurum, v_sube, v_tarih);
        if not found then continue; end if;

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
                coalesce(r.pay_yuzde, 100), v_tutar, 1)
        on conflict (dagitim_id, taraf_id, rol) where dagitim_id is not null
        do update set tutar = excluded.tutar, taban = excluded.taban,
                      deger = excluded.deger, belge_tur = excluded.belge_tur,
                      plan_id = excluded.plan_id, plan_satir_id = excluded.plan_satir_id
        -- DONDURULMUS satira dokunma (326).
        where hakedis_satir.durum = 1;

        v_sayac := v_sayac + 1;
    end loop;

    return v_sayac;
end $$;

-- prim.hedef_tur kod listesi artik KULLANILMIYOR (kapsam tipi kampanya
--   listesinden geliyor); kayitlar duruyor ama karta baglanmiyor.
