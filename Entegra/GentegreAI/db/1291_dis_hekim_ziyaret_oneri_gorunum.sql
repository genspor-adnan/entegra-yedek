-- =============================================================================
--  1291  v_dis_hekim_ziyaret: oneri kolonu (1290 tamamlayıcı - plan sayfası öneriyi kesik çerçeveyle çizer)
-- =============================================================================
\set ON_ERROR_STOP on

-- Kolon sırası değişiyor (oneri aktarim_kaynak'tan önce): replace izin vermez, görünüm düşürülüp kurulur.
drop view if exists public.v_dis_hekim_ziyaret;
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

do $$ begin raise notice '1291 tamam: v_dis_hekim_ziyaret.oneri.'; end $$;
