-- =====================================================================
--  558_prim_kategori_alt_agac.sql
--  Prim kapsamı "Kategori" seçildiğinde ALT AĞACI da kapsar.
--
--  328'deki eşleşme düz eşitlikti: `s.hedef_id = hizmet.kategori`. Kategoriler
--  O GÜN TEK SEVİYEYDİ, doğruydu. 553-556 ile ağaç iki seviye oldu
--  ("Laboratuvar > Biyokimya", "Tıbbi Malzeme > Ortez / Protez") ve kalemin
--  `kategori` alanı artık ALT dalı gösteriyor. Bu hâliyle "Laboratuvar"
--  kapsamlı bir prim satırı HİÇBİR kalemle eşleşmezdi - prim sessizce sıfır
--  çıkardı.
--
--  Kural: kapsam kategorisi, kalemin kategorisinin KENDİSİ ya da ÜSTÜ ise
--  satır uygulanır. Ağaç kaç seviye olursa olsun çalışsın diye özyineleme.
--
--  ÖZGÜLLÜK: alt dal seçen satır, üst dal seçenden ÖNCE gelmeli - yoksa
--  "Laboratuvar %5" kuralı "Biyokimya %8"i bastırırdı. Sıralamaya kapsamın
--  DERİNLİĞİ eklendi (kalemin kendi dalına yakın olan kazanır).
--
--  GÖVDE 380'DEN ALINDI (güncel imza: `p_tahsilat_turu` + `prim_zamani`);
--  yalnız kategori eşleşmesi ve sıralama satırı değişti.
-- =====================================================================

-- Kategorinin kendisi + tum ustleri. derinlik 0 = kalemin kendi dali.
create or replace function public.fn_kategori_ust_zinciri(p_kategori integer)
returns table (id integer, derinlik integer)
language sql stable as $$
    with recursive zincir as (
        select k.id, k.ust_id, 0 as derinlik
          from public.kategori k where k.id = p_kategori
        union all
        select u.id, u.ust_id, z.derinlik + 1
          from public.kategori u join zincir z on u.id = z.ust_id)
    select zincir.id, zincir.derinlik from zincir;
$$;

comment on function public.fn_kategori_ust_zinciri(integer) is
  'Kategorinin kendisi ve tum ustleri; derinlik 0 = kalemin kendi dali (558).';

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
       and p.rol = p_rol
       and (not exists (select 1 from public.prim_plani_taraf t
                         where t.plan_id = p.id)
            or exists (select 1 from public.prim_plani_taraf t
                        where t.plan_id = p.id and t.taraf_id = p_taraf_id))
       -- ODEYEN TIPI (380): 0 = tumu. Kurumu olmayan basvuru "Özel (Ücretli)".
       and (coalesce(p.odeyen_tipi, 0) = 0
            or p.odeyen_tipi = coalesce((select k.tur from public.taraf_kurum k
                                          where k.id = p_kurum_id), 1))
       and (coalesce(p.odeyen_kurum_id, 0) = 0 or p.odeyen_kurum_id = p_kurum_id)
       and (coalesce(p.sube_id, 0) = 0 or p.sube_id = p_sube_id)
       -- KAPSAM: Liste = tumu · Kategori (ALT AGAC, 558) · Urun
       and (s.tip = 1
            or (s.tip = 2 and (
                   (coalesce(s.kalem_turu, 0) in (0, 2)
                    and s.hedef_id in (select z.id from public.fn_kategori_ust_zinciri(
                            (select h.kategori from public.hizmet h
                              where h.id = p_hizmet_id)) z))
                or (coalesce(s.kalem_turu, 0) in (0, 1)
                    and s.hedef_id in (select z.id from public.fn_kategori_ust_zinciri(
                            (select st.kategori from public.stok st
                              where st.id = p_stok_id)) z))))
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
       -- Tip kisiti da OZGULLUK: "SGK'da %15" plani, tipsiz genel plani ezer.
       + (case when coalesce(p.odeyen_tipi, 0) <> 0 then 1 else 0 end)
       + (case when coalesce(p.odeyen_kurum_id, 0) <> 0 then 1 else 0 end) desc,
       -- KATEGORI DERINLIGI (558): kalemin kendi dalina EN YAKIN kapsam once.
       --   Kategori disindaki tiplerde 0 - eski sira degismez.
       (case when s.tip = 2 then
             coalesce((select min(z.derinlik)
                         from public.fn_kategori_ust_zinciri(
                                coalesce((select h.kategori from public.hizmet h
                                           where h.id = p_hizmet_id),
                                         (select st.kategori from public.stok st
                                           where st.id = p_stok_id))) z
                        where z.id = s.hedef_id), 99)
             else 0 end) asc,
       p.oncelik desc, s.sira, s.id
     limit 1;
$function$;

comment on function public.fn_prim_plan_satiri is
  'Kalem+rol icin EN DAR eslesen prim plan satiri (324; kapsam 328/380; kategori alt agaci 558).';
