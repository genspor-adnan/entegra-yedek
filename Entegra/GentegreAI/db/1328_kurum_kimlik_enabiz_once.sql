-- 1328 - Kurum kimliği: e-Nabız (şube → kurum geneli) önce, kurum profili yalnız YEDEK
--
-- Kullanıcı 12.11.2026 (kod incelemesi, seçenek 1): "her yerde geçerli ana ayarlar enabız ayarları olsun" kararıyla
-- uyum. 1323 şube PROFİLİNİ kurum geneli e-Nabız'ın önüne koymuştu; ama profildeki SKRS / Bakanlık adı artık ekrandan
-- düzenlenemiyor - şubede kalmış eski / test kodu kurum geneli e-Nabız'ı eziyor, düzeltmenin yolu yoktu.
-- Yeni sıra, alan alan: şube e-Nabız → kurum geneli e-Nabız → şube profili → kurum geneli profil → eski yer.
-- Şubeye özel kod gerekiyorsa o şubeye kendi e-Nabız satırı açılır. Dönüş sütunları 1323 ile aynı.
--
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

drop function if exists public.fn_kurum_kimlik(integer);
create function public.fn_kurum_kimlik(p_sube integer)
returns table (sube_id integer, ad varchar, skrs varchar, tesis varchar, kaynak varchar, enabiz_hesap_id integer, sube_enabiz_id integer)
language sql stable as $$
  with es as (            -- şubenin KENDİ e-Nabız satırı
    select h.id, btrim(coalesce(h.kurum_kodu, '')) as skrs,
           btrim(coalesce(h.ayarlar ->> 'medulaTesisKodu', '')) as tesis, btrim(coalesce(h.ayarlar ->> 'bakanlikAd', '')) as ad
      from public.entegrasyon_hesap h
     where h.kod = 'ENABIZ' and h.aktif = 1 and coalesce(p_sube, 0) <> 0 and h.sube_id = p_sube
     order by h.test_mi, h.id limit 1
  ), eg as (              -- kurum geneli e-Nabız satırı
    select h.id, btrim(coalesce(h.kurum_kodu, '')) as skrs,
           btrim(coalesce(h.ayarlar ->> 'medulaTesisKodu', '')) as tesis, btrim(coalesce(h.ayarlar ->> 'bakanlikAd', '')) as ad
      from public.entegrasyon_hesap h
     where h.kod = 'ENABIZ' and h.aktif = 1 and h.sube_id is null
     order by h.test_mi, h.id limit 1
  )
  select coalesce(p_sube, 0),
         coalesce(nullif(es.ad, ''), nullif(eg.ad, ''), nullif(ks.bakanlik_ad, ''), nullif(k0.bakanlik_ad, ''),
                  nullif(sb.unvan, ''), sb.ad,
                  (select coalesce(nullif(s1.unvan, ''), s1.ad) from public.sube s1 where s1.aktif = 1 order by s1.id limit 1), '')::varchar,
         coalesce(nullif(es.skrs, ''), nullif(eg.skrs, ''), nullif(ks.skrs_kodu, ''), nullif(k0.skrs_kodu, ''),
                  (select r.deger from public.referans r where r.anahtar = 'kurum.skrs_kodu'), '')::varchar,
         coalesce(nullif(es.tesis, ''), nullif(eg.tesis, ''), nullif(ks.tesis_kodu, ''), nullif(k0.tesis_kodu, ''),
                  (select m.kurum_kodu from public.entegrasyon_hesap m
                    where m.kod = 'MEDULA' and btrim(coalesce(m.kurum_kodu, '')) <> ''
                    order by (m.sube_id = p_sube) desc nulls last, m.test_mi nulls last, m.id limit 1), '')::varchar,
         (case when nullif(es.skrs, '') is not null then 'e-Nabız (şube)'
               when nullif(eg.skrs, '') is not null then 'e-Nabız (kurum geneli)'
               when nullif(ks.skrs_kodu, '') is not null then 'kurum profili (şube)'
               else 'kurum profili / eski ayar' end)::varchar,
         coalesce(es.id, eg.id),
         es.id
    from (select 1) z
    left join es on true
    left join eg on true
    left join public.kurum_profil ks on ks.sube_id = coalesce(p_sube, 0) and coalesce(p_sube, 0) <> 0
    left join public.kurum_profil k0 on k0.sube_id = 0
    left join public.sube sb on sb.id = p_sube
$$;
comment on function public.fn_kurum_kimlik(integer) is
  '1328: şubenin Bakanlık kimliği - alan alan şube e-Nabız → kurum geneli e-Nabız → şube profili → kurum geneli profil → eski yer (profil yalnız yedek). sube_enabiz_id = şubenin kendi e-Nabız satırı.';


commit;
