-- ============================================================================
--  380 - PRIM PLANINDA ODEYEN TIPI (kurum yerine grup)
--
--  Kullanici: "kurumlar ayrı ayrı olmasın - Tümü / Özel (Ücretli) / ÖSS / SGK,
--  4 tane yeter, gruplu".
--
--  NEDEN DOGRU: prim orani kurumun KIMLIGINE degil TURUNE gore degisiyor.
--  "Anlasmali sigortalarda %15" demek isteyen kullanici, her yeni sigorta
--  sozlesmesinde plan acmak zorunda kalmamali - kurum eklendigi anda dogru
--  gruba dusmeli. Tersi (kurum bazli plan) yeni kurumu SESSIZCE plansiz
--  birakirdi.
--
--  Tip kaynagi `taraf_kurum.tur` (1 Özel/Ücretli, 2 ÖSS, 3 SGK) - zaten var
--  olan ayrim; prim yeni bir siniflandirma UYDURMAZ.
--
--  KURUMU OLMAYAN BASVURU (kendi odeyen) tip 1 sayilir: hasta parayi kendi
--  odüyor, "Özel (Ücretli)" tam olarak bu.
--
--  odeyen_kurum_id kolonu DURUYOR ve eslestirmede hala okunuyor - tek bir
--  kuruma ozel istisna gerekirse yolu acik; kartta sorulmuyor.
-- ============================================================================

alter table public.prim_plani
  add column if not exists odeyen_tipi smallint not null default 0;

comment on column public.prim_plani.odeyen_tipi is
  'Planin ODEYEN TIPI (380): 0 tümü, 1 Özel (Ücretli), 2 ÖSS, 3 SGK - '
  'taraf_kurum.tur ile ayni kodlar. Kurumu olmayan basvuru (kendi odeyen) '
  '1 sayilir. Kurum KIMLIGI degil TURU sorulur: yeni sigorta sozlesmesi '
  'eklendiginde plan acmak gerekmesin.';

-- Var olan planlar kuruma bagliysa o kurumun turu yazilir - davranis korunur.
update public.prim_plani p
   set odeyen_tipi = coalesce((select k.tur from public.taraf_kurum k
                                where k.id = p.odeyen_kurum_id), 0)
 where p.odeyen_kurum_id is not null and coalesce(p.odeyen_tipi, 0) = 0;

-- ================================================================= kod listesi
insert into public.kod_liste (kod, ad)
select 'prim.odeyen_tipi', 'Prim Ödeyen Tipi'
 where not exists (select 1 from public.kod_liste where kod = 'prim.odeyen_tipi');

insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
select kl.id, x.deger, x.ad, x.sira, 1
  from public.kod_liste kl
  cross join (values (0, 'Tümü', 1), (1, 'Özel (Ücretli)', 2),
                     (2, 'ÖSS', 3), (3, 'SGK', 4)) as x(deger, ad, sira)
 where kl.kod = 'prim.odeyen_tipi'
   and not exists (select 1 from public.kod_deger d
                    where d.liste_id = kl.id and d.deger = x.deger);

-- ============================================================== eslestirme ===
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
       -- Tip kisiti da OZGULLUK: "SGK'da %15" plani, tipsiz genel plani ezer.
       + (case when coalesce(p.odeyen_tipi, 0) <> 0 then 1 else 0 end)
       + (case when coalesce(p.odeyen_kurum_id, 0) <> 0 then 1 else 0 end) desc,
       p.oncelik desc, s.sira, s.id
     limit 1;
$function$;
