-- =============================================================================
--  1096  DELPHI AKTARIMI - CARİ BAKİYE MUTABAKATI   (dokuman/18 §11, adım 7 açığı)
--
--  Kimlik mutabakatı (1091) kaydın VARLIĞINI denetler; bu, carinin TL bakiyesini.
--  Ajan Delphi'de cari başına bakiyeyi Delphi ekstre kuralıyla hesaplar (1085
--  eşdeğerlik testindeki kural: KASA cari satırları + hesap satırlarının carisi
--  olduğu gibi, faturalar TUR 15/16/17 borç - 8/11/12/13 alacak, iade ters, DURUM 6
--  hariç) - hareket_baslangic'tan, web'de bakiyeye girmeyen kasa türleri hariç
--  (kasa_islem_turu.bakiye_dahil = 0: tahsilat planı, avans...). Sunucu web
--  ekstresinden (v_cari_ekstre, bakiye_dahil = 1) aynı tarihten hesaplar.
--  Tolerans 0,05 TL. Sonuç aktarim_mutabakat'a tablo 'CARI_BAKIYE' (eksik = farklı
--  cari sayısı, ornek = en büyük farklar).
-- =============================================================================

begin;

-- p: [[rehber_id, tl_bakiye], ...] (Delphi)
create or replace function public.fn_aktarim_bakiye_mutabakat(p jsonb)
returns jsonb language sql stable as $$
    with d as (
        select (e->>0)::bigint id, (e->>1)::numeric tutar from jsonb_array_elements(coalesce(p, '[]')) e
    ), bas as (
        select coalesce((select public.fn_aktarim_zaman(nullif(deger, '')::timestamp) from public.aktarim_ayar
                          where anahtar = 'hareket_baslangic'), '-infinity'::timestamptz) t
    ), w as (
        select t.aktarim_id id, round(sum(e.yerel_borc - e.yerel_alacak), 2) tutar
          from public.v_cari_ekstre e
          join public.taraf t on t.id = e.taraf_id and t.aktarim_kaynak = 1 and t.aktarim_tablo = 'REHBER'
         where e.bakiye_dahil = 1 and e.islem_tarihi >= (select t from bas)
         group by t.aktarim_id
    ), k as (
        select coalesce(d.id, w.id) id, coalesce(d.tutar, 0) delphi, coalesce(w.tutar, 0) web
          from d full join w on w.id = d.id
    )
    select jsonb_build_object(
        'cari', (select count(*) from k),
        'farkli', (select count(*) from k where abs(delphi - web) > 0.05),
        'ornek', coalesce((select jsonb_agg(jsonb_build_object('id', x.id, 'unvan', x.unvan, 'delphi', x.delphi, 'web', x.web))
                             from (select k.id, k.delphi, k.web,
                                          (select tr.unvan from public.taraf tr
                                            where tr.aktarim_kaynak = 1 and tr.aktarim_tablo = 'REHBER' and tr.aktarim_id = k.id) unvan
                                     from k where abs(k.delphi - k.web) > 0.05
                                    order by abs(k.delphi - k.web) desc limit 20) x), '[]'))
$$;

comment on function public.fn_aktarim_bakiye_mutabakat(jsonb) is
    '1096: Delphi cari TL bakiyeleri <-> web ekstresi (hareket_baslangic''tan, bakiye_dahil); 0,05 TL tolerans.';

commit;
