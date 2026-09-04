-- ============================================================================
--  379 - PRIM ROLU PLAN BASLIGINA
--
--  Kullanici: "prim planina prim zamani saginda Prim Rolü zorunlu olarak ekle"
--  (ve satir gridinden rol kalkacak).
--
--  NEDEN DOGRU: bir prim plani "kime, hangi sifatla" sorusunun cevabidir -
--  "MR gonderen hekime %20". Rolu satir satir sormak, ayni planin iceride iki
--  farkli soruya cevap vermesine izin veriyordu; oranlari okurken hangi
--  satirin kime ait oldugu ancak rol kolonuna bakinca anlasiliyordu.
--
--  COK ROLLU PLAN BOLUNUR. Bugun plan 1 hem Gönderen (1) hem Raporlayan (5)
--  satirlari tasiyor. Plan basligina TEK rol yazip satirlari oldugu gibi
--  birakmak, Raporlayan satirlarini sessizce Gönderen primi haline getirirdi -
--  yanlis para. Bu yuzden goc her ROL icin AYRI PLAN uretir, satirlari ve
--  kisi listesini tasir: davranis birebir korunur, yalnizca iki plan gorunur.
--
--  prim_plani_satir.rol KOLONU DURUYOR (tarihsel/denetim izi) ama eslestirme
--  artik plan rolunu okur; kartta da sorulmaz.
-- ============================================================================

alter table public.prim_plani
  add column if not exists rol smallint not null default 1;

comment on column public.prim_plani.rol is
  'Planin PRIM ROLU (379): Gönderen / Yapan / Raporlayan... Eskiden her satirda '
  'ayri sorulurdu; plan "kime hangi sifatla" sorusunun cevabi oldugu icin '
  'basliga tasindi. prim_plani_satir.rol tarihsel olarak duruyor, eslestirme '
  'bu kolonu okur.';

-- ========================================================== cok rollu bolme ==
do $$
declare
    p        record;
    r        record;
    v_yeni   integer;
    v_rol_ad text;
begin
    for p in
        select s.plan_id, count(distinct s.rol) as rol_sayisi
          from public.prim_plani_satir s
         group by s.plan_id
        having count(distinct s.rol) > 1
    loop
        -- Ilk rol ASIL PLANDA kalir; kalan her rol icin kopya plan uretilir.
        for r in
            select distinct s.rol from public.prim_plani_satir s
             where s.plan_id = p.plan_id
             order by s.rol offset 1
        loop
            select coalesce(kd.ad, 'Rol ' || r.rol) into v_rol_ad
              from public.kod_liste kl
              join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = r.rol
             where kl.kod = 'prim.rol';

            insert into public.prim_plani
                   (kod, ad, baslangic, bitis, odeyen_kurum_id, sube_id, baz,
                    kdv_haric, oncelik, durum, aciklama, prim_zamani, rol,
                    ekleyen, degistiren)
            select left(nullif(e.kod, '') || '-' || r.rol, 30),
                   left(e.ad || ' — ' || v_rol_ad, 120),
                   e.baslangic, e.bitis, e.odeyen_kurum_id, e.sube_id, e.baz,
                   e.kdv_haric, e.oncelik, e.durum,
                   left(coalesce(nullif(e.aciklama, '') || ' | ', '')
                        || '379: rol bazli bolundu', 300),
                   e.prim_zamani, r.rol, e.ekleyen, e.degistiren
              from public.prim_plani e
             where e.id = p.plan_id
            returning id into v_yeni;

            update public.prim_plani_satir
               set plan_id = v_yeni
             where plan_id = p.plan_id and rol = r.rol;

            -- Kisi listesi de kopyalanir: kapsam plan basliginda tanimli.
            insert into public.prim_plani_taraf (plan_id, taraf_id, aciklama)
            select v_yeni, t.taraf_id, t.aciklama
              from public.prim_plani_taraf t
             where t.plan_id = p.plan_id
            on conflict (plan_id, taraf_id) do nothing;

            raise notice 'Plan % rol % icin % olarak bolundu', p.plan_id, r.rol, v_yeni;
        end loop;
    end loop;
end $$;

-- ============================================================== plan rolu ====
-- Artik her planin satirlari TEK rol tasiyor; o rol basliga yazilir.
update public.prim_plani p
   set rol = (select min(s.rol) from public.prim_plani_satir s where s.plan_id = p.id)
 where exists (select 1 from public.prim_plani_satir s where s.plan_id = p.id);

-- ============================================================= eslestirme ====
create or replace function public.fn_prim_plan_satiri(
    p_rol smallint, p_taraf_id integer, p_hizmet_id integer, p_stok_id integer,
    p_belge_tur smallint, p_pay smallint, p_kurum_id integer, p_sube_id integer,
    p_tarih date, p_tahsilat_turu smallint default 0)
returns table(plan_id integer, satir_id integer, oran_tipi smallint,
              deger numeric, alt_sinir numeric, ust_sinir numeric,
              baz smallint, prim_zamani smallint)
language sql
stable
as $function$
    select p.id, s.id, s.oran_tipi, s.deger, s.alt_sinir, s.ust_sinir, p.baz,
           coalesce(p.prim_zamani, 1)
      from public.prim_plani p
      join public.prim_plani_satir s on s.plan_id = p.id
     where coalesce(p.durum, 1) = 1
       and p.baslangic <= p_tarih
       and (p.bitis is null or p.bitis >= p_tarih)
       -- ROL ARTIK PLANIN (379): satirdaki rol kolonu tarihsel.
       and p.rol = p_rol
       -- KISI LISTESI (375): bos = herkes, dolu = yalnizca listedekiler.
       and (not exists (select 1 from public.prim_plani_taraf t
                         where t.plan_id = p.id)
            or exists (select 1 from public.prim_plani_taraf t
                        where t.plan_id = p.id and t.taraf_id = p_taraf_id))
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
       + (case when exists (select 1 from public.prim_plani_taraf t
                             where t.plan_id = p.id) then 1 else 0 end)
       + (case when coalesce(p.odeyen_kurum_id, 0) <> 0 then 1 else 0 end) desc,
       p.oncelik desc, s.sira, s.id
     limit 1;
$function$;
