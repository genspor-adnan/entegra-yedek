-- 1297 - Saha ziyareti ERP kipi: müşteri ziyareti (kullanıcı 11.11.2026)
--
-- "ziyaret sisteminin erp ve hbys modu olsun.. hbys de dış doktorlar, erp de
-- ise müşteriler ziyaret edilir". Ziyaret / talep / vade / plan / performans
-- aynı tablolarda kalır; ZİYARET EDİLEN TARAF kipe göre:
--   HBYS (fn_urun_modu = 2): taraf_personel.dis_hekim = 1 (dış doktor)
--   ERP  (fn_urun_modu = 1): taraf.musteri = 1 and taraf.personel = 0 (müşteri)
--   3 (ikisi): her ikisi.
-- "Gönderim" ERP'de SATIŞ: satış faturası / fişi (belge.tur 15, 16; iade
-- tipi 2 sayılmaz; durum 0) - vade görünümü ve performans ucu birleşim okur.
-- Müşteri kartına ziyaret sıklığı / tercih gün-saat (taraf kolonları;
-- dış doktorda taraf_personel'de kalır, görünümler coalesce eder).
--
-- Tekrar çalıştırılabilir.
begin;

-- ---------------------------------------------------------------- taraf: müşteri ziyaret ayarı
alter table public.taraf add column if not exists ziyaret_sikligi_hafta smallint not null default 0;
alter table public.taraf add column if not exists tercih_gun smallint;
alter table public.taraf add column if not exists tercih_saat varchar(5);
comment on column public.taraf.ziyaret_sikligi_hafta is
  '1297: MÜŞTERİ saha ziyaret sıklığı (hafta; 0 = planlanmaz). Dış doktorda taraf_personel.ziyaret_sikligi_hafta.';
comment on column public.taraf.tercih_gun  is '1297: müşteri ziyaret tercih günü (1 Pzt .. 7 Paz).';
comment on column public.taraf.tercih_saat is '1297: müşteri ziyaret tercih saati (ss:dd).';

-- ---------------------------------------------------------------- ziyaret edilen taraf seçimi (kipe göre)
create or replace view public.v_saha_hedef_lookup as
select t.id,
       public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as ad,
       coalesce(public.fn_taraf_ad(k.unvan, k.ad, k.soyad)::varchar(120), '')::text as kurum,
       coalesce(kd.ad, '') as brans,
       t.durum as aktif
  from public.taraf t
  left join public.taraf_personel p on p.id = t.id
  left join public.taraf k on k.id = t.bag_id
  left join public.kod_liste kl on kl.kod = 'hekim.brans'
  left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger::text = nullif(p.brans, '')
 where coalesce(t.durum, 1) = 1
   and ((coalesce(p.dis_hekim, 0) = 1 and public.fn_urun_modu(0) <> 1)
        or (t.musteri = 1 and t.personel = 0 and public.fn_urun_modu(0) <> 2));
comment on view public.v_saha_hedef_lookup is
  '1297: saha ziyaretinde ziyaret edilen taraf - HBYS dış doktor, ERP müşteri, kip 3 ikisi (fn_urun_modu).';

-- ---------------------------------------------------------------- tetikler: müşteri de hedef olabilir
create or replace function public.tg_dis_hekim_temsilci_dogrula()
returns trigger language plpgsql as $$
declare
    v_ad text;
begin
    if not exists (select 1 from public.taraf t left join public.taraf_personel p on p.id = t.id
                    where t.id = new.hekim_id
                      and (coalesce(p.dis_hekim, 0) = 1 or (t.musteri = 1 and t.personel = 0))) then
        raise exception 'Temsilci yalnız dış doktora ya da müşteriye bağlanır (taraf %).', new.hekim_id using errcode = 'GK422';
    end if;
    if not exists (select 1 from public.taraf t join public.taraf_personel p on p.id = t.id
                    where t.id = new.temsilci_id and t.personel = 1 and coalesce(p.dis_hekim, 0) = 0) then
        raise exception 'Temsilci kurum personeli olmalı (taraf %).', new.temsilci_id using errcode = 'GK422';
    end if;
    if coalesce(new.aktif, 1) = 1 then
        select public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::text into v_ad
          from public.dis_hekim_temsilci d
          join public.taraf t on t.id = d.temsilci_id
         where d.hekim_id = new.hekim_id and d.sube_id = new.sube_id and d.id <> coalesce(new.id, 0)
           and coalesce(d.aktif, 1) = 1
           and d.baslangic <= coalesce(new.bitis, date '9999-12-31')
           and coalesce(d.bitis, date '9999-12-31') >= new.baslangic
         limit 1;
        if v_ad is not null then
            raise exception 'Bu şube için aynı tarihlerde % zaten temsilci; önce onun bitişini yazın.', v_ad
                  using errcode = 'GK422';
        end if;
    end if;
    return new;
end $$;

create or replace function public.tg_dis_hekim_talep_hazirla()
returns trigger language plpgsql as $$
begin
    if new.ziyaret_id is not null and (new.hekim_id is null or coalesce(new.sube_id, 0) = 0) then
        select coalesce(new.hekim_id, z.hekim_id), case when coalesce(new.sube_id, 0) = 0 then z.sube_id else new.sube_id end
          into new.hekim_id, new.sube_id
          from public.dis_hekim_ziyaret z where z.id = new.ziyaret_id;
    end if;
    if new.hekim_id is null then
        raise exception 'Talebin ziyaret edilen tarafı (doktor / müşteri) belirtilmeli.' using errcode = 'GK422';
    end if;
    if new.durum in (3, 4) and new.kapanma is null then new.kapanma := now(); end if;
    if new.durum in (1, 2) then new.kapanma := null; end if;
    return new;
end $$;

-- ---------------------------------------------------------------- vade görünümü: müşteri + satış
create or replace view public.v_dis_hekim_ziyaret_vade as
with hekim as (
    -- Dış doktor (HBYS): sıklık taraf_personel'den.
    select t.id as hekim_id, t.sube_id as kayit_sube, t.temsilci as varsayilan_temsilci, t.ekleme_tarihi,
           coalesce(p.ziyaret_sikligi_hafta, 0)::int as siklik_hafta
      from public.taraf t
      join public.taraf_personel p on p.id = t.id and coalesce(p.dis_hekim, 0) = 1
     where coalesce(t.durum, 1) = 1
    union all
    -- Müşteri (ERP): sıklık taraf'tan (1297).
    select t.id, t.sube_id, t.temsilci, t.ekleme_tarihi, coalesce(t.ziyaret_sikligi_hafta, 0)::int
      from public.taraf t
     where t.musteri = 1 and t.personel = 0 and coalesce(t.durum, 1) = 1
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
  '1290/1297: ziyaret edilen taraf (dış doktor HBYS / müşteri ERP) × şube × temsilci ziyaret vadesi; gönderim = radyoloji istemi + satış belgesi.';

-- ---------------------------------------------------------------- yetki / rehber: her iki kip
update public.yetki set urun_modu = 0
 where kod in ('dis_doktor.ziyaret', 'dis_doktor.talep', 'dis_doktor.vade', 'dis_doktor.plan', 'dis_doktor.performans')
   and urun_modu <> 0;
update public.ai_rehber_ekran set urun_modu = 0
 where yetki_kodu in ('dis_doktor.ziyaret', 'dis_doktor.talep', 'dis_doktor.vade', 'dis_doktor.plan', 'dis_doktor.performans')
   and urun_modu <> 0;

-- Rol açıklamaları kipsiz.
update public.rol set amac = 'Saha ziyaretleri (HBYS dış doktor / ERP müşteri), talepler, ziyaret vadesi ve haftalık plan; ziyaret edilen kartı düzenler, silmez.'
 where kod = 'saha_temsilci' and sistem = 1;
update public.rol set amac = 'Temsilcinin ekranları + silme, şube temsilcisi atama, Saha Performansı, prim planı görme.'
 where kod = 'saha_sorumlu' and sistem = 1;

commit;
