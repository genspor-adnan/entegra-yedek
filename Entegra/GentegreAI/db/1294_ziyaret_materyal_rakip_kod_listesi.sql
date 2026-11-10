-- =============================================================================
--  1294  ZİYARET: BIRAKILAN MATERYAL VE RAKİP BASKISI KOD LİSTESİ  (kullanıcı 10.11.2026: "bırakılan materyal ve rakip
--        baskısı alanları combo olsun, label'a basarak eklenebilsin")
--  Serbest metin kolonları kod listesine bağlanır (kartta etikete tıklayınca liste düzenlenir - kartAlanCizim
--  listeDuzenle deseni). Kolonlar boştu (dört yerel DB'de 0 dolu satır); smallint'e çevrilir.
-- =============================================================================
\set ON_ERROR_STOP on

insert into public.kod_liste (kod, ad)
select v.kod, v.ad from (values ('dis_hekim.materyal', 'Dış Doktor Bırakılan Materyal'),
                                ('dis_hekim.rakip',    'Dış Doktor Rakip Baskısı'),
                                ('dis_hekim.konu',     'Dış Doktor Görüşme Konusu')) v(kod, ad)
 where not exists (select 1 from public.kod_liste k where k.kod = v.kod);

insert into public.kod_deger (liste_id, deger, ad, sira)
select kl.id, v.deger, v.ad, v.deger
  from (values
    ('dis_hekim.materyal', 1, 'Fiyat listesi'), ('dis_hekim.materyal', 2, 'Broşür'), ('dis_hekim.materyal', 3, 'Protokol kitapçığı'),
    ('dis_hekim.materyal', 4, 'İstek kâğıdı'), ('dis_hekim.materyal', 5, 'Promosyon'), ('dis_hekim.materyal', 9, 'Diğer'),
    ('dis_hekim.rakip', 1, 'Fiyat'), ('dis_hekim.rakip', 2, 'Rapor süresi'), ('dis_hekim.rakip', 3, 'Cihaz / kalite'),
    ('dis_hekim.rakip', 4, 'Yakınlık'), ('dis_hekim.rakip', 5, 'Kişisel ilişki'), ('dis_hekim.rakip', 9, 'Diğer'),
    -- GÖRÜŞÜLEN KONULAR (kullanıcı: seçimli rozetler): dis_hekim_ziyaret.konular virgüllü kod listesi.
    ('dis_hekim.konu', 1, 'Rapor süresi'), ('dis_hekim.konu', 2, 'Fiyat / rakip'), ('dis_hekim.konu', 3, 'Protokol'),
    ('dis_hekim.konu', 4, 'Randevu'), ('dis_hekim.konu', 5, 'Cihaz / teknoloji'), ('dis_hekim.konu', 6, 'Eğitim'),
    ('dis_hekim.konu', 7, 'Sonuç erişimi'), ('dis_hekim.konu', 8, 'Şikâyet'), ('dis_hekim.konu', 9, 'Diğer')
  ) v(liste, deger, ad)
  join public.kod_liste kl on kl.kod = v.liste
 where not exists (select 1 from public.kod_deger d where d.liste_id = kl.id and d.deger = v.deger);

-- Görünüm kolonu kullanıyor: düşürülür, sonunda konular_ad ile yeniden kurulur.
drop view if exists public.v_dis_hekim_ziyaret;

do $$
begin
  if (select data_type from information_schema.columns where table_name = 'dis_hekim_ziyaret' and column_name = 'materyal') <> 'smallint' then
    alter table public.dis_hekim_ziyaret alter column materyal drop default;
    alter table public.dis_hekim_ziyaret alter column materyal type smallint using coalesce(nullif(materyal, '')::smallint, 0);
    alter table public.dis_hekim_ziyaret alter column materyal set default 0;
  end if;
  if (select data_type from information_schema.columns where table_name = 'dis_hekim_ziyaret' and column_name = 'rakip') <> 'smallint' then
    alter table public.dis_hekim_ziyaret alter column rakip drop default;
    alter table public.dis_hekim_ziyaret alter column rakip type smallint using coalesce(nullif(rakip, '')::smallint, 0);
    alter table public.dis_hekim_ziyaret alter column rakip set default 0;
  end if;
end $$;
comment on column public.dis_hekim_ziyaret.materyal is '1294: kod listesi dis_hekim.materyal (0 yok).';
comment on column public.dis_hekim_ziyaret.rakip is '1294: kod listesi dis_hekim.rakip (0 yok).';

create view public.v_dis_hekim_ziyaret as
select z.id, z.hekim_id, z.temsilci_id, z.sube_id, z.tarih, z.tur, z.amac, z.sonuc, z.durum, z.sure_dk, z.notu, z.konular,
       z.memnuniyet, z.rakip, z.materyal, z.sonraki_tarih, z.hatirlat, z.hatirlatma_id, z.bas_zamani, z.bit_zamani,
       z.bas_enlem, z.bas_boylam, z.bit_enlem, z.bit_boylam, z.mobil, z.goruldu_id, z.goruldu_zamani, z.plan_id, z.oneri,
       z.aktarim_kaynak, z.ekleyen, z.ekleme_tarihi,
       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '')   as hekim_ad,
       coalesce(public.fn_taraf_ad(k.unvan, k.ad, k.soyad)::varchar(120), '')   as hekim_kurum,
       coalesce((select a.ilce from public.taraf_adres a where a.taraf_id = z.hekim_id and coalesce(a.aktif, 1) = 1
                  order by a.varsayilan desc, a.id limit 1), '')                 as hekim_ilce,
       coalesce(public.fn_taraf_ad(tm.unvan, tm.ad, tm.soyad)::varchar(120), '') as temsilci_ad,
       coalesce(s.ad, '')                                                        as sube_ad,
       coalesce(kt.ad, '')                                                       as tur_ad,
       coalesce(ka.ad, '')                                                       as amac_ad,
       case z.durum when 0 then 'Planlı' when 2 then 'İptal' else coalesce(ks.ad, 'Yapıldı') end as sonuc_ad,
       (select count(*) from public.dis_hekim_talep t where t.ziyaret_id = z.id)::int                        as talep_sayisi,
       (select count(*) from public.dis_hekim_talep t where t.ziyaret_id = z.id and t.durum in (1, 2))::int  as acik_talep,
       (select count(*) from public.dis_hekim_ziyaret_yorum y where y.ziyaret_id = z.id)::int                as yorum_sayisi,
       -- KONULAR (1294): virgüllü kod -> ad listesi.
       coalesce((select string_agg(kd.ad, ', ' order by kd.sira, kd.deger) from public.kod_liste kl
                   join public.kod_deger kd on kd.liste_id = kl.id
                  where kl.kod = 'dis_hekim.konu' and kd.deger::text = any(string_to_array(z.konular, ','))), '') as konular_ad,
       coalesce(public.fn_taraf_ad(g.unvan, g.ad, g.soyad)::varchar(120), '')   as goruldu_ad
  from public.dis_hekim_ziyaret z
  join public.taraf h on h.id = z.hekim_id
  left join public.taraf k on k.id = h.bag_id
  left join public.taraf tm on tm.id = z.temsilci_id
  left join public.taraf g on g.id = z.goruldu_id
  left join public.sube s on s.id = z.sube_id
  left join public.kod_liste lt on lt.kod = 'dis_hekim.ziyaret_turu'
  left join public.kod_deger kt on kt.liste_id = lt.id and kt.deger = z.tur
  left join public.kod_liste la on la.kod = 'dis_hekim.ziyaret_amaci'
  left join public.kod_deger ka on ka.liste_id = la.id and ka.deger = z.amac
  left join public.kod_liste ls on ls.kod = 'dis_hekim.ziyaret_sonucu'
  left join public.kod_deger ks on ks.liste_id = ls.id and ks.deger = z.sonuc;

do $$ begin raise notice '1294 tamam: materyal / rakip / konu kod listeleri, v_dis_hekim_ziyaret.konular_ad.'; end $$;
