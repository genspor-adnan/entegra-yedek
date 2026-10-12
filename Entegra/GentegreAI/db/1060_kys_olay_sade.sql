-- =============================================================================
--  1060  KURUMSAL KALİTE - OLAY BİLDİRİMİ MOCKUP'A UYDU (Kalite2/olay_bildirim.html)
--
--  Kullanıcı (12.10.2026): "olay bildirimini mockup gibi yap". Sade mockup:
--    Tür  : Uygunsuzluk · Müşteri şikâyeti · İş güvenliği · Ramak kala · Diğer
--    Etki : Düşük · Orta · Yüksek  (kolon adı `zarar` kalır, liste kys.olay_zarar)
--    Liste: No · Tarih · Tür · Konu · Birim · Etki · Durum ("Kapandı · DÖF-2026-019")
--  1052'deki hastane listeleri (hasta / çalışan / tesis güvenliği, 6 zarar
--  düzeyi) KOBİ'ye uymuyordu.
--
--  Değerler YALNIZ hiç olay kaydı yoksa değiştirilir: kayıt varsa eski kodun
--  anlamı değişmiş olurdu (tür 1 "Hasta güvenliği" -> "Uygunsuzluk"). O
--  durumda liste aynen kalır, NOTICE verilir. İdempotent.
-- =============================================================================

begin;

do $$
declare v_tur int; v_zarar int;
begin
  select id into v_tur   from public.kod_liste where kod = 'kys.olay_tur';
  select id into v_zarar from public.kod_liste where kod = 'kys.olay_zarar';

  if exists (select 1 from public.kalite_olay) then
    raise notice '1060: kalite_olay dolu - tür / etki listeleri DEĞİŞTİRİLMEDİ.';
    return;
  end if;

  delete from public.kod_deger where liste_id = v_tur
     and (deger, ad) not in (values (1, 'Uygunsuzluk'), (2, 'Müşteri şikâyeti'), (3, 'İş güvenliği'), (4, 'Ramak kala'), (9, 'Diğer'));
  insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
  select v_tur, v.deger, v.ad, v.sira, 1, 0
    from (values (1, 'Uygunsuzluk', 10), (2, 'Müşteri şikâyeti', 20), (3, 'İş güvenliği', 30),
                 (4, 'Ramak kala', 40), (9, 'Diğer', 90)) as v(deger, ad, sira)
   where not exists (select 1 from public.kod_deger d where d.liste_id = v_tur and d.deger = v.deger);

  delete from public.kod_deger where liste_id = v_zarar
     and (deger, ad) not in (values (1, 'Düşük'), (2, 'Orta'), (3, 'Yüksek'));
  insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
  select v_zarar, v.deger, v.ad, v.deger * 10, 1, 0
    from (values (1, 'Düşük'), (2, 'Orta'), (3, 'Yüksek')) as v(deger, ad)
   where not exists (select 1 from public.kod_deger d where d.liste_id = v_zarar and d.deger = v.deger);
end $$;

update public.kod_liste set ad = 'Kalite Olay Etkisi' where kod = 'kys.olay_zarar' and ad = 'Kalite Olay Zarar Düzeyi';

-- Liste: konu (açıklamanın ilk satırı) + kapanmış bildirimin DÖF'ü. DÖF bağı
--   kalite_dof.kaynak_tur = 2 / kaynak_id üzerinden (1050 sözleşmesi);
--   kalite_olay.dof_id DÖF ucunda doldurulmuyor. Yeni kolonlar SONA eklenir.
create or replace view public.v_kalite_olay as
select o.id, o.no, o.tarih, o.tur, coalesce(kt.ad, '') as tur_adi,
       o.departman_id, coalesce(d.ad, '') as birim_adi,
       o.zarar, coalesce(kz.ad, '') as zarar_adi,
       o.anonim,
       case when o.anonim = 1 then 'Anonim' else coalesce(public.fn_taraf_ad(e.unvan, e.ad, e.soyad), '') end as bildiren_adi,
       o.komite_id, coalesce(k.ad, '') as komite_adi,
       coalesce(o.dof_id, df.id) as dof_id, o.durum,
       case o.durum when 1 then 'Yeni' when 2 then 'Değerlendirmede'
                    when 3 then 'Kapandı' || coalesce(' · ' || df.no, '') else '' end as durum_adi,
       o.sube_id,
       left(split_part(o.aciklama, E'\n', 1), 160)::varchar(160) as konu,
       coalesce(df.no, '')::varchar(20) as dof_no
  from public.kalite_olay o
  left join public.kod_liste lt on lt.kod = 'kys.olay_tur'
  left join public.kod_deger kt on kt.liste_id = lt.id and kt.deger = o.tur
  left join public.kod_liste lz on lz.kod = 'kys.olay_zarar'
  left join public.kod_deger kz on kz.liste_id = lz.id and kz.deger = o.zarar
  left join public.departman d on d.id = o.departman_id
  left join public.taraf e on e.id = o.ekleyen and o.anonim = 0
  left join public.kalite_komite k on k.id = o.komite_id
  left join lateral (select x.id, x.no from public.kalite_dof x
                      where x.kaynak_tur = 2 and x.kaynak_id = o.id and x.durum <> 9
                      order by x.id desc limit 1) df on true;

commit;
