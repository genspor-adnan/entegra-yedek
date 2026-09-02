-- 331: KURUM TAHAKKUKU akışında primin doğru belgeden okunması.
--
-- Kullanıcı: "kurum tahakkukunu gerçek akışa bağla, prim tahsilat sayılmasın."
--
-- Kurum tahakkuku bir TAHSİLAT DEĞİL: hastadan para alınmaz, kurum payı
-- kuruma kesilen belgeye (Satış Tahakkuku, tür 13) dönüşür ve kurum carisine
-- borç yazılır. Kasa işlemi olmadığı için prim de doğmaz - prim yalnız
-- tahsilat dağıtımından (321) üretilir. Bu dosya prim tarafındaki TEK
-- eksiği kapatır:
--
--   Aynı kalem İKİ ayrı belgeye bölünebilir - hasta payı satış fişine,
--   kurum payı kurum tahakkukuna. 330'daki zincir okuması "en son halka"yı
--   alıyordu; kurum tahakkuku kesildikten sonra HASTA payının primi de
--   tahakkuk oranıyla hesaplanabilirdi. Belge türü artık PAYA göre seçilir:
--   kurum payı kuruma kesilen belgeden, hasta payı hastaya kesilenden.

drop function if exists public.fn_prim_belge_turu(integer);

create or replace function public.fn_prim_belge_turu(
    p_satir_id integer, p_pay smallint default 0)
returns smallint language sql stable as $$
    with recursive zincir(satir_id, tur, taraf_id, derinlik) as (
        select s.id, b.tur, b.taraf_id, 0
          from public.belge_satir s
          join public.belge b on b.id = s.belge_id
         where s.id = p_satir_id
        union all
        select h.id, b2.tur, b2.taraf_id, z.derinlik + 1
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
    )
    select coalesce(
      -- 1) Paya UYGUN dal: kurum payi KURUMA kesilen belgeden, hasta payi
      --    hastaya kesilenden okunur.
      (select z.tur
         from zincir z cross join kurum k
        where z.derinlik > 0
          and ((p_pay = 2 and z.taraf_id = k.odeyen_kurum_id)
            or (p_pay = 1 and z.taraf_id is distinct from k.odeyen_kurum_id))
        order by z.derinlik desc, z.satir_id desc limit 1),
      -- 2) Paylasim yoksa (normal satis) zincirin sonuncu halkasi.
      (select z.tur from zincir z order by z.derinlik desc, z.satir_id desc limit 1));
$$;

comment on function public.fn_prim_belge_turu is
  'Kalemin GELIR belgesi turu (330/331): donusum zincirinin sonu, PAYA uygun dal.';

-- fn_prim_uret: belge turunu satirin PAYIYLA sorar.
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
    -- 331: belge turu PAYA gore - kurum payi kurum tahakkukundan okunur.
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

-- 330'daki durum gecisi de ayni fonksiyonu kullaniyordu; imza degistigi icin
--   mevcut satirlarin belge turu/durumu yeniden hesaplanir (idempotent).
update public.hakedis_satir h
   set belge_tur = public.fn_prim_belge_turu(h.belge_satir_id, h.pay),
       durum = case when public.fn_prim_taslak_mi(
                         public.fn_prim_belge_turu(h.belge_satir_id, h.pay))
                    then 1 else 2 end
 where h.durum in (1, 2);
