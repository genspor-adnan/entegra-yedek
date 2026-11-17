-- 1360 - HASTA FİŞİ (belge türü 128) - hasta tahakkuku yerine (17.11.2026).
--   Kullanıcı: "hasta tahakkuk ile kurum tahakkuk tamamen farklı.. hasta tahakkukta takip yok.. sadece belge ile
--   kapatmak için.. kurum tahakkukta ödeme vb takipler olmalı" · "eğer karışıyorsa sadece hastaya özel 'Hasta Fişi'
--   diye bir belge de üretebiliriz" · "evet, hasta fişi yap, eskileri de çevir".
--
--   Başvurunun HASTA payını belgeleyip kapatan belge. Muhasebe davranışı Satış Tahakkuku (17) ile aynı (cari
--   borçlanır, ekstre / bakiye), ama ödeme takibine (kurum icmali, yaşlandırma, tahsilat sekmesi kurum belgeleri,
--   kurum tahakkuku akışları) GİRMEZ - artık bunu türü söyler; cari adı karşılaştırması gerekmez.
--   17 "Satış Tahakkuku" kurum tahakkuku olarak kalır.
--   KOD 128: 28 / 29 Delphi aktarımında hediye / iade çeki tahsilatıdır (fn_aktar_kasa) - çakışmasın diye satışın
--   üç haneli bloğu (119 konsinyenin yanı).
--
--   ESKİLERİN ÇEVRİLMESİ: başvurudan (kaynak_tur 30) doğmuş, başvurunun hastasına kesilmiş VE bütün satırları hasta
--   kovasında (pay 1 provizyon hasta payı / 4 ek katkı) olan 17'ler 128 olur - belge ve mali hareketleri
--   (belge_satir.tur kalem türüdür, dokunulmaz).
--   Önce yedeklenir (yedek.hasta_fisi_1360). Belge numarası değişmez. Tekrar çalıştırılabilir.

-- -------------------------------------------------------------- tür ----
insert into public.kasa_islem_turu (kod, ad, grup, yon, ana_hesap_turu, karsi_hesap_turu, cari_zorunlu, kalem_turu,
       plan_mi, cari_ekstre, hesap_ekstre, bakiye_dahil, fis_mi, fis_turu, sablon, makbuz_basligi, makbuz_seri, sira,
       aktif, stok_etkiler, cari_etkiler)
select 128, 'Hasta Fişi', grup, yon, ana_hesap_turu, karsi_hesap_turu, cari_zorunlu, kalem_turu,
       plan_mi, cari_ekstre, hesap_ekstre, bakiye_dahil, fis_mi, fis_turu, sablon, makbuz_basligi, makbuz_seri, 956,
       aktif, stok_etkiler, cari_etkiler
  from public.kasa_islem_turu where kod = 17
on conflict (kod) do nothing;

-- ------------------------------------------------- türü bilen fonksiyonlar ----
-- Satış yönü (cari borçlanır, stok etkilemez) - BelgeTuru.CikisTurleri ile aynı küme.
create or replace function public.fn_belge_cikis_mi(p_tur integer, p_tipi integer)
returns boolean language sql immutable as $$
    select case when p_tipi = 2 and p_tur not in (9, 18, 19, 20, 105, 3, 4)
                then not (p_tur in (17, 128, 14, 15, 16, 119, 29, 105, 133, 4, 121, 123))
                else p_tur in (17, 128, 14, 15, 16, 119, 29, 105, 133, 4, 121, 123) end
$$;

-- Muhasebe fişi üretmez (tahakkuk gibi): bilinmeyen tür fişlenir sayılırdı.
create or replace function public.fn_belge_fis_turu_uygun(p_tur integer)
returns boolean language sql immutable as $$
    -- Fişlenmeyen (mali sonuç faturada doğan) belgeler:
    --   9/19 sipariş · 18 teklif · 105 talep · 10/14 irsaliye ·
    --   109/119 konsinye · 20 transfer · 13/17 tahakkuk · 128 hasta fişi (1360) · 30 eski başvuru ·
    --   121/122/123 üretim sarf / mamul girişi / fire (429) ·
    --   3/4 stok giriş / çıkış fişi (1167 - gider/gelir eşlemesi gelene kadar).
    select coalesce(p_tur, 0)
           not in (3, 4, 9, 10, 13, 14, 17, 18, 19, 20, 30, 105, 109, 119,
                   121, 122, 123, 128);
$$;

-- Kısa ad (tahsilat açıklaması "... Tahsilatı"): istemcideki belgeKisaAdi ile aynı.
create or replace function public.fn_belge_kisa_adi(p_tur integer, p_tipi integer default 0)
returns varchar
language sql
immutable
as $$
    select case
        when p_tur = 19 and p_tipi = 30 then 'Başvuru'
        when p_tur = 18                 then 'Teklif'
        when p_tur = 20                 then 'Transfer'
        when p_tur = 105                then 'Talep'
        when p_tur in (9, 19)           then 'Sipariş'
        when p_tur in (109, 119)        then 'Konsinye'
        when p_tur in (13, 17)          then 'Tahakkuk'
        when p_tur = 128                then 'Hasta Fişi'
        when p_tur in (10, 14)          then 'İrsaliye'
        when p_tur in (3, 4, 12, 16)    then 'Fiş'
        when p_tur in (11, 15)          then 'Fatura'
        else 'Belge'
    end::varchar;
$$;

-- Numaralama ekranı satış türleri (KaynakKatalogu.Numara NumaraSatisTurleri ile aynı).
create or replace view public.v_numara_turu_satis as
    select kod::integer as id, ad, aktif from public.kasa_islem_turu
     where kod in (17, 128, 14, 15, 16, 19, 119);  -- tahakkuk/hasta fişi/irsaliye/fatura/fis/siparis/konsinye

-- Cari özeti: hasta fişi satış (ciro, son satış) sayılır - yoksa borcu "ödeme" gibi okunurdu.
create or replace view public.v_cari_ozet as
with yp as materialized (
    select public.fn_yerel_para()::text as kod
),
h as materialized (
    -- VADE: hareketin plan tarihi; yoksa işlem tarihi + carinin vade günü (müşteride taraf_musteri,
    --   alış belgelerinde taraf_tedarikci).
    select e.taraf_id, e.tur, e.islem_tarihi,
           coalesce(e.plan_tarihi, e.islem_tarihi + make_interval(days =>
               case when e.tur in (11, 12, 13) then coalesce(tt.vade_gun, tm.vade_gun, 0) else coalesce(tm.vade_gun, 0) end)) as vade,
           e.doviz_cinsi, e.borc, e.alacak, e.yerel_borc, e.yerel_alacak
      from public.v_mali_hareket_ek e
      left join public.taraf_musteri tm on tm.id = e.taraf_id
      left join public.taraf_tedarikci tt on tt.id = e.taraf_id
     where e.hesap_turu = 'C' and e.cari_ekstre = 1 and e.islem_durum in (1, 2)
       and e.bakiye_dahil = 1 and e.taraf_id is not null
),
bakiye as materialized (
    select h.taraf_id,
           sum(h.yerel_borc - h.yerel_alacak) as bakiye,
           greatest(coalesce(sum(h.yerel_borc) filter (where h.vade < date_trunc('day', now())), 0)
                    - sum(h.yerel_alacak), 0) as vadesi_gecen,
           -- TEDARİKÇİ GÖZÜ (1162): alacak tarafı aynı kural - ödemeler (borç) önce vadesi en eski borcumuzu kapatır.
           greatest(coalesce(sum(h.yerel_alacak) filter (where h.vade < date_trunc('day', now())), 0)
                    - sum(h.yerel_borc), 0) as vadesi_gecen_odeme,
           greatest(coalesce(sum(h.yerel_alacak) filter (where h.vade < date_trunc('day', now()) + interval '30 days'), 0)
                    - sum(h.yerel_borc), 0)
             - greatest(coalesce(sum(h.yerel_alacak) filter (where h.vade < date_trunc('day', now())), 0)
                    - sum(h.yerel_borc), 0) as odenecek_30,
           max(h.islem_tarihi) filter (where h.tur in (15, 16, 17, 128) and h.yerel_borc > 0) as son_satis,
           max(h.islem_tarihi) filter (where h.yerel_alacak > 0 and h.tur not in (15, 16, 17, 128, 11, 12, 13)) as son_tahsilat,
           max(h.islem_tarihi) filter (where h.tur in (11, 12, 13) and h.yerel_alacak > 0) as son_alis,
           max(h.islem_tarihi) filter (where h.yerel_borc > 0 and h.tur not in (15, 16, 17, 128, 11, 12, 13)) as son_odeme,
           sum(h.yerel_borc - h.yerel_alacak) filter (
               where h.tur in (15, 16, 17, 128) and h.islem_tarihi >= date_trunc('month', now()) - interval '11 months') as ciro_12ay,
           sum(h.yerel_borc - h.yerel_alacak) filter (
               where h.tur in (15, 16, 17, 128) and h.islem_tarihi >= date_trunc('year', now())) as ciro_bu_yil,
           sum(h.yerel_borc - h.yerel_alacak) filter (
               where h.tur in (15, 16, 17, 128) and h.islem_tarihi >= date_trunc('year', now()) - interval '1 year'
                 and h.islem_tarihi < now() - interval '1 year') as ciro_gecen_yil,
           sum(h.yerel_alacak - h.yerel_borc) filter (
               where h.tur in (11, 12, 13) and h.islem_tarihi >= date_trunc('month', now()) - interval '11 months') as alis_12ay,
           sum(h.yerel_alacak - h.yerel_borc) filter (
               where h.tur in (11, 12, 13) and h.islem_tarihi >= date_trunc('year', now())) as alis_bu_yil,
           sum(h.yerel_alacak - h.yerel_borc) filter (
               where h.tur in (11, 12, 13) and h.islem_tarihi >= date_trunc('year', now()) - interval '1 year'
                 and h.islem_tarihi < now() - interval '1 year') as alis_gecen_yil
      from h
     group by h.taraf_id
),
doviz as materialized (
    select x.taraf_id, string_agg(x.doviz_cinsi || ':' || x.b::text, ';' order by x.doviz_cinsi) as doviz_bakiye
      from (select h.taraf_id, h.doviz_cinsi, sum(h.borc - h.alacak) as b
              from h, yp
             where h.doviz_cinsi <> yp.kod
             group by h.taraf_id, h.doviz_cinsi
            having abs(sum(h.borc - h.alacak)) >= 0.005) x
     group by x.taraf_id
),
ay as materialized (
    select h.taraf_id, date_trunc('month', h.islem_tarihi) as ay,
           sum(h.yerel_borc - h.yerel_alacak) filter (where h.tur in (15, 16, 17, 128)) as t,
           sum(h.yerel_alacak - h.yerel_borc) filter (where h.tur in (11, 12, 13)) as a
      from h
     where h.tur in (15, 16, 17, 128, 11, 12, 13) and h.islem_tarihi >= date_trunc('month', now()) - interval '11 months'
     group by 1, 2
),
egri as materialized (
    select k.taraf_id, string_agg(round(coalesce(a.t, 0))::text, ',' order by g.ay) as ciro_egri,
           string_agg(round(coalesce(a.a, 0))::text, ',' order by g.ay) as alis_egri
      from (select distinct taraf_id from ay) k
     cross join generate_series(date_trunc('month', now()) - interval '11 months',
                                date_trunc('month', now()), interval '1 month') g(ay)
      left join ay a on a.taraf_id = k.taraf_id and a.ay = g.ay
     group by k.taraf_id
)
select b.taraf_id, b.bakiye, b.vadesi_gecen, b.son_satis, b.son_tahsilat,
       coalesce(b.ciro_12ay, 0) as ciro_12ay, coalesce(b.ciro_bu_yil, 0) as ciro_bu_yil,
       coalesce(b.ciro_gecen_yil, 0) as ciro_gecen_yil,
       coalesce(d.doviz_bakiye, '') as doviz_bakiye, coalesce(e.ciro_egri, '') as ciro_egri,
       b.vadesi_gecen_odeme, b.odenecek_30, b.son_alis, b.son_odeme,
       coalesce(b.alis_12ay, 0) as alis_12ay, coalesce(b.alis_bu_yil, 0) as alis_bu_yil,
       coalesce(b.alis_gecen_yil, 0) as alis_gecen_yil, coalesce(e.alis_egri, '') as alis_egri
  from bakiye b
  left join doviz d on d.taraf_id = b.taraf_id
  left join egri e on e.taraf_id = b.taraf_id;

comment on view public.v_cari_ozet is
    '1150 + 1162 (+1327 materialized ara adımlar, +1360 Hasta Fişi 128 satış): cari basina bakiye, doviz bakiyeleri, vadesi gecen (alacak ve ODEME), 30 gunde odenecek, son satis / tahsilat / alis / odeme, 12 ay ciro ve ALIM + aylik egriler. Musteri ve Tedarikci Listesi Ver3.';


-- ------------------------------------------------------------ prim ----
-- Prim ölçütü "Fatura / Fiş" (hasta payı) Hasta Fişi'ni de kapsar (KartKatalogu.Kodlar PrimBelgeTuruKodlari).
--   Belge türü değişince prim yeniden üretildiği için (tg_prim_belge_tur) ÇEVİRMEDEN ÖNCE.
update public.prim_plani_satir set belge_turleri = '15,16,128' where belge_turleri = '15,16';

-- ------------------------------------------------- eskilerin çevrilmesi ----
create schema if not exists yedek;
create table if not exists yedek.hasta_fisi_1360 (belge_id integer primary key, belge_no varchar(40),
       taraf_id integer, genel_toplam numeric, eski_tur smallint, yedek_zamani timestamptz default now());

do $$
declare v_sayi integer;
begin
  create temp table _hf on commit drop as
  select b.id
    from public.belge b
    join public.belge k on k.id = b.kaynak_id
   where b.tur = 17 and b.kaynak_tur = 30 and b.taraf_id = k.taraf_id
     and exists (select 1 from public.belge_satir s where s.belge_id = b.id)
     and not exists (select 1 from public.belge_satir s where s.belge_id = b.id and coalesce(s.pay, 0) not in (1, 4));

  insert into yedek.hasta_fisi_1360 (belge_id, belge_no, taraf_id, genel_toplam, eski_tur)
  select b.id, b.belge_no, b.taraf_id, b.genel_toplam, b.tur from public.belge b join _hf on _hf.id = b.id
  on conflict (belge_id) do nothing;

  update public.belge b set tur = 128 from _hf where _hf.id = b.id;
  get diagnostics v_sayi = row_count;
  update public.mali_hareket m set tur = 128 from _hf where _hf.id = m.belge_id and m.tur = 17;
  raise notice '1360: % hasta tahakkuku Hasta Fişi (128) oldu (yedek.hasta_fisi_1360)', v_sayi;
end $$;
