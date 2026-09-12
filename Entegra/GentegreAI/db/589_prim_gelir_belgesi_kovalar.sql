-- =====================================================================
--  589_prim_gelir_belgesi_kovalar.sql
--  Faturalama primi: DÖRT KOVANIN da gelir belgesi bulunur.
--
--  Kullanıcı: "tahakkuka dönüştü ama hakediş satırı gelmedi."
--
--  `fn_prim_uret_belge` her dolu kova için (1 hasta provizyon · 2 SGK ·
--  3 ÖSS · 4 hasta ek katkı) ayrı prim üretir ve her biri için kalemin
--  GELİR BELGESİNİ sorar. `fn_prim_gelir_belgesi` ise dönüşüm zincirindeki
--  dalı yalnız İKİ kova için eşliyordu:
--        pay 2 -> tarafı ödeyen kurum olan belge
--        pay 1 -> tarafı ödeyen kurum OLMAYAN belge (hasta)
--  Kovalar 492'de dörde çıkarken burası güncellenmemiş. Sonuç: ödeyen kurumu
--  olan başvuruda tutar 3 (ÖSS) ya da 4 (hasta ek katkı) kovasındaysa hiçbir
--  dal eşleşmiyor, kaynağın kendi türü (19 başvuru) dönüyor ve üretim
--  "henüz faturalanmamış" diye atlıyordu - tahakkuk kesilse bile prim yok.
--
--  Doğru eşleme ÖDEYENE göredir:
--        kurum payları  (2 SGK, 3 ÖSS) -> tarafı ödeyen kurum olan belge
--        hasta payları  (1 provizyon, 4 ek katkı) -> tarafı kurum OLMAYAN belge
--  Paysız satır (0) eskisi gibi zincirin son halkasını kullanır.
--
--  Fonksiyonun geri kalanı (zincir, derinlik sınırı, paya uygun dal yoksa
--  kaynağın türünü döndürme) aynen korunur.
-- =====================================================================

create or replace function public.fn_prim_gelir_belgesi(
    p_satir_id integer, p_pay smallint default 0)
returns table(tur smallint, tarih date, belge_id integer)
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
           -- KURUM PAYLARI kuruma, HASTA PAYLARI hastaya kesilen belgeden (589).
           and ((p_pay in (2, 3) and z.taraf_id = k.odeyen_kurum_id)
             or (p_pay in (1, 4) and z.taraf_id is distinct from k.odeyen_kurum_id))
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
    -- Paya uygun dal yoksa o pay henuz BELGELENMEMISTIR: kaynagin kendi turu
    --   (siparis/basvuru) doner ve cagiran tarafta "taslak" sayilir.
    select coalesce(p.tur, g.tur, k.tur)::smallint,
           coalesce(p.tarih, g.tarih, k.tarih),
           coalesce(p.belge_id, g.belge_id, k.belge_id)
      from kaynak k
      left join paya_uygun p on true
      left join genel g on true;
$$;
