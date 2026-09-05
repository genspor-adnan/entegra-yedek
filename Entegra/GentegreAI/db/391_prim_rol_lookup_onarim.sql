-- ============================================================================
--  391 - v_prim_rol_lookup KIRIKTI: fn_basvuru_hekim_rolu'nun ESKI IMZASI
--
--  364 fonksiyonu sube parametreli hale getirdi (`fn_basvuru_hekim_rolu(integer
--  default 0)`) ve `kurum_profil.id` kolonunu kaldirdi. Ama 361'den kalan
--  PARAMETRESIZ imza (`fn_basvuru_hekim_rolu()`) SILINMEDI; govdesi hâlâ
--  `where p.id = 1` diyor. View onu parametresiz cagirdigi icin eski imzaya
--  bagliydi ve her okumada patliyordu:
--
--    ERROR: column p.id does not exist
--    CONTEXT: SQL function "fn_basvuru_hekim_rolu" during inlining
--
--  Etkisi: v_prim_rol_lookup'u kullanan HER yer (prim plani rol combosu,
--  "Prim Alanlar" sekmesi, hakedis satirlari serit suzgeci) veri getiremiyordu.
--
--  Cozum iki adim - sirasi onemli: once view ACIK cagriya (0 = kurum geneli,
--  eski davranisin ayni) cevrilir ki eski imzaya bagimlilik kalksin, sonra o
--  imza dusurulur. Ters sirada DROP "other objects depend on it" ile reddedilir.
-- ============================================================================

create or replace view public.v_prim_rol_lookup as
with roller(id, ad, sira) as (
    values (1::smallint, 'Gönderen'::varchar, 1), (2, 'İsteyen', 2),
           (3, 'Uygulayan', 3), (4, 'Yapan', 4), (5, 'Raporlayan', 5),
           (6, 'Onaylayan', 6), (7, 'Anestezi', 7), (8, 'Asistan', 8),
           (9, 'Teknisyen', 9)
)
select r.id,
       (r.ad || case when public.fn_prim_rol_aday_sayisi(r.id::smallint) = 0
                     then ' — aktif kişi işaretlenmemiş'
                     else ' (' || public.fn_prim_rol_aday_sayisi(r.id::smallint)::text
                          || ' kişi)'
                end)::varchar as ad,
       1::smallint as aktif,
       -- 391: ACIK argument - parametresiz cagri eski (kirik) imzaya baglaniyordu.
       (case when r.id::smallint = public.fn_basvuru_hekim_rolu(0) then 0 else 1 end) * 100
         + case when public.fn_prim_rol_aday_sayisi(r.id::smallint) > 0 then 0 else 50 end
         + r.sira as sira
  from roller r;

drop function if exists public.fn_basvuru_hekim_rolu();
