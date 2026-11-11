-- 1300 - Ziyaret sırası görünümü kipe bağlı (HBYS dış doktor / ERP müşteri)
--
-- 1297 görünüme müşteriyi de kattı ama kip süzgeci koymadı: HBYS kurulumunda (cari kayıtları da olan) "sırası
-- gelenler" ve özet kutuları müşterileri sayıyordu (dev: 712 müşteri). v_saha_hedef_lookup ile AYNI kural:
-- dış doktor fn_urun_modu(0) <> 1 iken, müşteri fn_urun_modu(0) <> 2 iken; kip 3 ikisi.
--
-- Tekrar çalıştırılabilir.
begin;
create or replace view public.v_dis_hekim_ziyaret_vade as
with hekim as (
    -- Dış doktor (HBYS): sıklık taraf_personel'den.
    select t.id as hekim_id, t.sube_id as kayit_sube, t.temsilci as varsayilan_temsilci, t.ekleme_tarihi,
           coalesce(p.ziyaret_sikligi_hafta, 0)::int as siklik_hafta
      from public.taraf t
      join public.taraf_personel p on p.id = t.id and coalesce(p.dis_hekim, 0) = 1
     where coalesce(t.durum, 1) = 1 and public.fn_urun_modu(0) <> 1
    union all
    -- Müşteri (ERP): sıklık taraf'tan (1297); kip HBYS ise girmez (1300).
    select t.id, t.sube_id, t.temsilci, t.ekleme_tarihi, coalesce(t.ziyaret_sikligi_hafta, 0)::int
      from public.taraf t
     where t.musteri = 1 and t.personel = 0 and coalesce(t.durum, 1) = 1 and public.fn_urun_modu(0) <> 2
),
bag as (
    select h.hekim_id, d.sube_id, d.temsilci_id, h.siklik_hafta, h.ekleme_tarihi
      from hekim h
      join public.dis_hekim_temsilci d on d.hekim_id = h.hekim_id and coalesce(d.aktif, 1) = 1
                                       and d.baslangic <= current_date and (d.bitis is null or d.bitis >= current_date)
    union all
    select h.hekim_id, h.kayit_sube, h.varsayilan_temsilci, h.siklik_hafta, h.ekleme_tarihi
      from hekim h
     where not exists (select 1 from public.dis_hekim_temsilci d where d.hekim_id = h.hekim_id and coalesce(d.aktif, 1) = 1
                         and d.baslangic <= current_date and (d.bitis is null or d.bitis >= current_date))
),
istem as (
    -- "Gönderim": HBYS radyoloji istemi, ERP satış faturası / fişi (iade sayılmaz).
    select x.hekim_id,
           count(*) filter (where x.zaman >= now() - interval '30 days')::int as son30,
           count(*) filter (where x.zaman >= now() - interval '60 days' and x.zaman < now() - interval '30 days')::int as onceki30,
           max(x.zaman) as son_istem
      from (select i.istek_hekim_id as hekim_id, coalesce(i.cekim_tarihi, i.ekleme_tarihi) as zaman
              from public.radyoloji_istem i
             where i.istek_hekim_id is not null and i.durum > 0
            union all
            select b.taraf_id, b.belge_tarihi::timestamp
              from public.belge b
             where b.tur in (15, 16) and coalesce(b.tipi, 0) <> 2 and b.durum = 0 and b.taraf_id is not null) x
     group by x.hekim_id
)
select b.hekim_id, b.sube_id, b.temsilci_id, b.siklik_hekim as siklik_hafta,
       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '')   as hekim_ad,
       coalesce(public.fn_taraf_ad(k.unvan, k.ad, k.soyad)::varchar(120), '')   as hekim_kurum,
       coalesce((select a.ilce from public.taraf_adres a where a.taraf_id = b.hekim_id and coalesce(a.aktif, 1) = 1
                  order by a.varsayilan desc, a.id limit 1), '')                 as hekim_ilce,
       coalesce(public.fn_taraf_ad(tm.unvan, tm.ad, tm.soyad)::varchar(120), '') as temsilci_ad,
       coalesce(s.ad, '')                                                        as sube_ad,
       z.son_ziyaret,
       case when b.siklik_hekim > 0 then coalesce(z.son_ziyaret::date, b.ekleme_tarihi::date) + b.siklik_hekim * 7 end as vade_tarihi,
       case when b.siklik_hekim > 0 and coalesce(z.son_ziyaret::date, b.ekleme_tarihi::date) + b.siklik_hekim * 7 < current_date
            then current_date - (coalesce(z.son_ziyaret::date, b.ekleme_tarihi::date) + b.siklik_hekim * 7) else 0 end::int as gecikme_gun,
       pl.id as planli_ziyaret_id, pl.tarih as planli_tarih, coalesce(pl.oneri, 0)::smallint as planli_oneri,
       (select count(*) from public.dis_hekim_talep t where t.hekim_id = b.hekim_id and t.durum in (1, 2))::int as acik_talep,
       coalesce(i.son30, 0) as son30_istem, coalesce(i.onceki30, 0) as onceki30_istem,
       case when coalesce(i.onceki30, 0) > 0 and coalesce(i.son30, 0) * 2 < coalesce(i.onceki30, 0) then 1 else 0 end::smallint as gonderim_dusen,
       i.son_istem,
       case when i.son_istem is null then null else (current_date - i.son_istem::date) end::int as sessiz_gun,
       case when b.ekleme_tarihi >= now() - interval '90 days' then 1 else 0 end::smallint as yeni_hekim
  from (select hekim_id, sube_id, temsilci_id, siklik_hafta as siklik_hekim, ekleme_tarihi from bag) b
  join public.taraf h on h.id = b.hekim_id
  left join public.taraf k on k.id = h.bag_id
  left join public.taraf tm on tm.id = b.temsilci_id
  left join public.sube s on s.id = b.sube_id
  left join lateral (select max(v.tarih) as son_ziyaret from public.dis_hekim_ziyaret v
                      where v.hekim_id = b.hekim_id and v.durum = 1
                        and (v.sube_id = b.sube_id or b.sube_id is null)) z on true
  left join lateral (select v.id, v.tarih, v.oneri from public.dis_hekim_ziyaret v
                      where v.hekim_id = b.hekim_id and v.durum = 0 and v.tarih >= current_date
                        and (v.temsilci_id = b.temsilci_id or b.temsilci_id is null)
                      order by v.tarih limit 1) pl on true
  left join istem i on i.hekim_id = b.hekim_id;

comment on view public.v_dis_hekim_ziyaret_vade is
  '1290/1297/1300: ziyaret edilen taraf (HBYS dış doktor / ERP müşteri, fn_urun_modu) × şube × temsilci ziyaret sırası; gönderim = radyoloji istemi + satış belgesi.';
commit;
