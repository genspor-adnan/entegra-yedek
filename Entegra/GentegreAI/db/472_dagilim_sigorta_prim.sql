-- =====================================================================
-- 472 - SİGORTA PROVİZYONU VE PRİM, DAĞILIM TABLOSUNA GEÇTİ
--
-- 470/471 dağılımı ve tahsilatı beş kovaya aldı. Provizyon dağıtımı hâlâ
-- `belge_satir.kurum_tutar/hasta_tutar`ı yazıyordu; prim ise kaba pay
-- (1 hasta / 2 kurum) üzerinden çalışıyordu.
--
-- SİGORTA ŞİRKETİNİN ONAYI = oss kovası. Rota kuralı `fn_belge_satir_dagit`
-- içindedir: TSS'de fark yutulur, Karma'da artan hastaya kalır. Bu göç
-- provizyonu KOVAYA yazmaz - dağıtımı fonksiyona bırakır, yoksa aynı kural
-- iki yerde durur ve zamanla ayrışırdı.
--
-- ASMED "katilim_payi" ≠ SGK KATILIM PAYI: sigortacının hasta katılımıdır,
-- hasta_provizyon kovasına girer. Karıştırılırsa hastadan alınan para SGK'ya
-- emanet yazılırdı.
--
-- PRİM kaba grupla çalışmaya devam eder (hasta/kurum): plan satırları o
-- uzayda yazılmış. İnce kod (beş kova) `fn_dagilim_pay_grubu` ile kabaya
-- indirilir - plan tablosuna dokunulmaz.
-- =====================================================================

-- ------------------------------------------------------- provizyon dağıtımı --
-- Satır satır tazele: dağıtım kuralı tek yerde (fn_belge_satir_dagilim_tazele
--   472'de tanımlanır; burada provizyon tutarını GEÇER, kovayı kendisi yazmaz).
create or replace function public.fn_belge_satir_dagilim_tazele(
    p_satir_id  integer,
    p_sgk_prov  numeric default null,
    p_oss_prov  numeric default null)
returns integer
language plpgsql as $$
declare
    s          record;
    v_rota     smallint;
    v_sgk_liste numeric := 0;
    v_huv      numeric := 0;
    v_ek       numeric := 0;
    v_katilim  numeric := 0;
    d          record;
    v_elle     smallint;
begin
    if coalesce(p_satir_id, 0) = 0 then return null; end if;

    select bs.id, bs.belge_id, bs.miktar, bs.tutar, bs.iskonto, bs.kdv,
           bs.stok_id, bs.hizmet_id, bs.birim_fiyat,
           b.belge_tarihi::date as tarih,
           bb.odeyen_kurum_id, bb.sozlesme_id, bb.alt_kurum, bb.sgk_kullan,
           k.tur as kurum_tur,
           sz.fiyat_listesi_id, sz.sgk_fiyat_listesi_id, sz.varsayilan_karsilama
      into s
      from public.belge_satir bs
      join public.belge b on b.id = bs.belge_id
      left join public.belge_basvuru bb on bb.id = bs.belge_id
      left join public.taraf_kurum k on k.id = bb.odeyen_kurum_id
      left join public.kurum_sozlesme sz on sz.id = bb.sozlesme_id
     where bs.id = p_satir_id;
    if not found then return null; end if;

    -- ELLE sabitlenmiş dağılıma dokunulmaz.
    select dg.elle into v_elle
      from public.belge_satir_dagilim dg where dg.belge_satir_id = p_satir_id;
    if coalesce(v_elle, 0) = 1 then return s.belge_id; end if;

    v_rota := public.fn_dagilim_rota(coalesce(s.kurum_tur, 1)::smallint,
                                     coalesce(s.alt_kurum, 0)::smallint,
                                     coalesce(s.sgk_kullan, 1)::smallint);

    -- Liste fiyatları MİKTARLA çarpılır ve iskonto satırdakiyle aynı uygulanır:
    --   kovalar satır matrahıyla aynı düzlemde olmalı.
    if s.sgk_fiyat_listesi_id is not null then
        v_sgk_liste := round(coalesce(public.fn_fiyat_listesi_fiyat(
                                 s.sgk_fiyat_listesi_id, s.stok_id, s.hizmet_id), 0)
                             * coalesce(s.miktar, 0)
                             * (1 - coalesce(s.iskonto, 0) / 100.0), 2);
        v_katilim := round(coalesce(public.fn_fiyat_listesi_katki(
                                 s.sgk_fiyat_listesi_id, s.stok_id, s.hizmet_id), 0)
                           * coalesce(s.miktar, 0), 2);
        v_ek := public.fn_fiyat_listesi_ek_katki(s.sgk_fiyat_listesi_id,
                                                 s.stok_id, s.hizmet_id, v_sgk_liste);
    end if;
    if s.fiyat_listesi_id is not null then
        v_huv := round(coalesce(public.fn_fiyat_listesi_fiyat(
                            s.fiyat_listesi_id, s.stok_id, s.hizmet_id), 0)
                       * coalesce(s.miktar, 0)
                       * (1 - coalesce(s.iskonto, 0) / 100.0), 2);
    end if;
    -- Liste çözülemiyorsa satırın kendi tutarı TTB yerine geçer: dağılım
    --   yine de yapılabilsin (kurumsuz/ERP satırı).
    if v_huv = 0 then v_huv := coalesce(s.tutar, 0); end if;

    select * into d from public.fn_belge_satir_dagit(
        v_rota, coalesce(s.tutar, 0), v_sgk_liste, v_huv, v_ek, v_katilim,
        p_sgk_prov, p_oss_prov, coalesce(s.varsayilan_karsilama, 0));

    -- ROTA 3/5'te satır tutarı KOVALARDAN çıkar: satırın kendisi yeniden yazılır.
    if v_rota in (3, 5) and coalesce(s.miktar, 0) > 0
       and abs(coalesce(s.tutar, 0) - d.tutar) > 0.005 then
        update public.belge_satir
           set birim_fiyat = round(d.tutar / s.miktar, 4),
               tutar       = d.tutar,
               tutar_kdvli = round(d.tutar * (1 + coalesce(s.kdv, 0) / 100.0), 2)
         where id = p_satir_id;
    end if;

    insert into public.belge_satir_dagilim
           (belge_satir_id, rota, sgk_liste, huv_liste, sgk, oss,
            hasta_provizyon, hasta_ek_katki, sgk_katilim_payi, degistirme_tarihi)
    values (p_satir_id, v_rota, v_sgk_liste, v_huv, d.sgk, d.oss,
            d.hasta_provizyon, d.hasta_ek_katki, d.sgk_katilim_payi, now())
    on conflict (belge_satir_id) do update
       set rota = excluded.rota, sgk_liste = excluded.sgk_liste,
           huv_liste = excluded.huv_liste, sgk = excluded.sgk, oss = excluded.oss,
           hasta_provizyon = excluded.hasta_provizyon,
           hasta_ek_katki = excluded.hasta_ek_katki,
           sgk_katilim_payi = excluded.sgk_katilim_payi,
           degistirme_tarihi = now();

    -- Eski kolonlar 474'e kadar okunuyor.
    update public.belge_satir bs
       set kurum_tutar = d.sgk + d.oss,
           hasta_tutar = d.hasta_provizyon + d.hasta_ek_katki,
           karsilama   = case when d.tutar > 0
                              then round((d.sgk + d.oss) * 100 / d.tutar, 4) else 0 end
     where bs.id = p_satir_id;

    return s.belge_id;
end $$;

comment on function public.fn_belge_satir_dagilim_tazele(integer, numeric, numeric) is
  'Satırın dağılımını sözleşme listelerinden yeniden hesaplar (472). Provizyon verilirse liste fiyatı yerine onaylanan geçer.';

-- ------------------------------------------------------- sigorta provizyonu --
create or replace function public.fn_sigorta_pay_dagit(p_provizyon_id integer)
returns integer language plpgsql as $$
declare
    r      record;
    v_sayi integer := 0;
    v_belge integer;
begin
    for r in
        select s.belge_satir_id, s.sirket_tutar, s.id as prov_satir_id,
               coalesce(s.katilim_payi, 0) as katilim
          from public.sigorta_provizyon_satir s
         where s.provizyon_id = p_provizyon_id and s.belge_satir_id is not null
    loop
        -- Sigortanın onayladığı tutar OSS kovasıdır; rotaya göre kalanı
        --   hastaya mı yazılır yoksa yutulur mu, dağıtım fonksiyonu bilir.
        v_belge := public.fn_belge_satir_dagilim_tazele(
                       r.belge_satir_id, null, round(r.sirket_tutar, 4));
        update public.belge_satir_dagilim
           set oss_provizyon_satir_id = r.prov_satir_id, degistirme_tarihi = now()
         where belge_satir_id = r.belge_satir_id;
        v_sayi := v_sayi + 1;
    end loop;

    if v_belge is not null then
        perform public.fn_belge_diptoplam(v_belge);
    end if;
    return v_sayi;
end $$;

comment on function public.fn_sigorta_pay_dagit(integer) is
  'Provizyon sonucunu satırlara işler (472): şirket tutarı OSS kovasına, kalan rotaya göre.';

-- Provizyon iptalinde dağılım LİSTE fiyatına döner: iptal edilen onayın
--   tutarı satırda kalırsa hasta payı sessizce yanlış hesaplanır.
create or replace function public.fn_sigorta_pay_geri_al(p_provizyon_id integer)
returns integer language plpgsql as $$
declare r record; v_sayi integer := 0; v_belge integer;
begin
    for r in
        select s.belge_satir_id
          from public.sigorta_provizyon_satir s
         where s.provizyon_id = p_provizyon_id and s.belge_satir_id is not null
    loop
        v_belge := public.fn_belge_satir_dagilim_tazele(r.belge_satir_id);
        update public.belge_satir_dagilim
           set oss_provizyon_satir_id = null, degistirme_tarihi = now()
         where belge_satir_id = r.belge_satir_id;
        v_sayi := v_sayi + 1;
    end loop;
    if v_belge is not null then
        perform public.fn_belge_diptoplam(v_belge);
    end if;
    return v_sayi;
end $$;

comment on function public.fn_sigorta_pay_geri_al(integer) is
  'Provizyon iptalinde satır dağılımını liste fiyatına döndürür (472).';

-- ---------------------------------------------------------------- prim --
-- Gelir belgesi hedefi kova koduna göre: SGK payı SGK carisine, ÖSS payı
--   ödeyen kuruma, hasta kovaları hastaya. Prim zinciri KABA grupla çalışır.
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
        -- Payın HEDEF CARİSİ: SGK payı sözleşmedeki SGK carisine, sigorta
        --   payı ödeyen kuruma yazılır. TSS/Karma'da bu ikisi FARKLIDIR.
        select case when p_pay = 2 then coalesce(sz.sgk_kurum_id, bb.odeyen_kurum_id)
                    else bb.odeyen_kurum_id end as odeyen_kurum_id
          from public.belge_satir s
          join public.belge_basvuru bb on bb.id = s.belge_id
          left join public.kurum_sozlesme sz on sz.id = bb.sozlesme_id
         where s.id = p_satir_id and bb.odeyen_kurum_id is not null
    ),
    paya_uygun as (
        select z.tur, z.tarih, z.belge_id
          from zincir z cross join kurum k
         where z.derinlik > 0
           and ((public.fn_dagilim_pay_grubu(p_pay) = 2 and z.taraf_id = k.odeyen_kurum_id)
             or (public.fn_dagilim_pay_grubu(p_pay) = 1
                 and z.taraf_id is distinct from k.odeyen_kurum_id))
         order by z.derinlik desc, z.satir_id desc limit 1
    ),
    genel as (
        select z.tur, z.tarih, z.belge_id from zincir z
         where not exists (select 1 from kurum)
         order by z.derinlik desc, z.satir_id desc limit 1
    ),
    kaynak as (
        select z.tur, z.tarih, z.belge_id from zincir z where z.derinlik = 0
    )
    select coalesce(p.tur, g.tur, k.tur)::smallint,
           coalesce(p.tarih, g.tarih, k.tarih),
           coalesce(p.belge_id, g.belge_id, k.belge_id)
      from kaynak k
      left join paya_uygun p on true
      left join genel g on true;
$$;

comment on function public.fn_prim_gelir_belgesi is
  'Kalemin gelir belgesi (472): kova koduna göre hedef cari - SGK payı sözleşmedeki SGK carisine.';

-- Hakediş satırlarındaki pay kodu da ince uzaya taşınır (kaba grup aynı kalır).
create table if not exists public._yedek_hakedis_pay_472 (
    hakedis_satir_id integer primary key,
    eski_pay smallint not null,
    yeni_pay smallint not null,
    tarih timestamp not null default now()
);

do $$
begin
    if to_regclass('public.hakedis_satir') is null then
        raise notice '472: hakedis_satir yok - pay tasimasi atlandi';
        return;
    end if;

    insert into public._yedek_hakedis_pay_472 (hakedis_satir_id, eski_pay, yeni_pay)
    select h.id, h.pay,
           case when h.pay = 2 then (case when dg.sgk > 0 then 2 else 3 end)
                when h.pay = 1 then (case when dg.hasta_provizyon > 0 then 1 else 4 end)
                else h.pay end
      from public.hakedis_satir h
      join public.belge_satir_dagilim dg on dg.belge_satir_id = h.belge_satir_id
     where h.pay in (1, 2)
    on conflict (hakedis_satir_id) do nothing;

    update public.hakedis_satir h
       set pay = y.yeni_pay
      from public._yedek_hakedis_pay_472 y
     where y.hakedis_satir_id = h.id and h.pay = y.eski_pay and h.pay <> y.yeni_pay;
end $$;

do $$
begin
    raise notice '472 tamam: % hakedis payi tasindi',
        (select count(*) from public._yedek_hakedis_pay_472);
end $$;
