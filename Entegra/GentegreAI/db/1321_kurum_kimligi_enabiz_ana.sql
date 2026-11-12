-- 1321 - Kurum kimliğinin ANA kaynağı e-Nabız hesabı (1317-1318'in yönü değişti)
--
-- Kullanıcı 12.11.2026: "her yerde geçerli ana ayarlar enabız ayarları olsun.. çünkü tüm hbys kullanan yerler enabız
-- kullanmak zorunda ama medula ya da teleradyoloji kullanmak zorunda değil".
--
-- Kimlik (SKRS kurum kodu, MEDULA tesis kodu, Bakanlık'ta görünen ad) artık Entegrasyon › ENABIZ hesabında - şube başına
-- satır (şube satırı → kurum geneli, canlı önce). Alanlar: kurum_kodu = SKRS kurum kodu (eskisi gibi), ayarlar.medulaTesisKodu,
-- ayarlar.bakanlikAd. TeleRadyoloji (ORC-21, KOS, doz), MEDULA ve Teleradyoloji teslimi fn_kurum_kimlik / fn_kurum_skrs /
-- fn_kurum_tesis ile buradan okur. e-Nabız hesabı yoksa ya da alan boşsa sırayla: kurum profili (1317 geçişinde taşınan
-- değerler) → eski yer (referans kurum.skrs_kodu; MEDULA hesabının kurum kodu). Hiçbir kurulum bozulmaz.
--
-- Veri: e-Nabız hesabında MEDULA tesis kodu / ad boşsa kurum profilindeki (1317) değer yazılır - tek yerde görünsün.
-- fn_kurum_kimlik'e `kaynak` sütunu eklendi (ekranda "nereden").
--
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

drop function if exists public.fn_kurum_kimlik(integer);
create function public.fn_kurum_kimlik(p_sube integer)
returns table (sube_id integer, ad varchar, skrs varchar, tesis varchar, kaynak varchar, enabiz_hesap_id integer)
language sql stable as $$
  with e as (
    select h.id, h.sube_id, btrim(coalesce(h.kurum_kodu, '')) as skrs,
           btrim(coalesce(h.ayarlar ->> 'medulaTesisKodu', '')) as tesis,
           btrim(coalesce(h.ayarlar ->> 'bakanlikAd', '')) as ad
      from public.entegrasyon_hesap h
     where h.kod = 'ENABIZ' and h.aktif = 1
       and (h.sube_id is null or (coalesce(p_sube, 0) <> 0 and h.sube_id = p_sube))
     order by (h.sube_id is null), h.test_mi, h.id
     limit 1
  )
  select coalesce(p_sube, 0),
         coalesce(nullif(e.ad, ''), nullif(ks.bakanlik_ad, ''), nullif(k0.bakanlik_ad, ''), nullif(sb.unvan, ''), sb.ad,
                  (select coalesce(nullif(s1.unvan, ''), s1.ad) from public.sube s1 where s1.aktif = 1 order by s1.id limit 1), '')::varchar,
         coalesce(nullif(e.skrs, ''), nullif(ks.skrs_kodu, ''), nullif(k0.skrs_kodu, ''),
                  (select r.deger from public.referans r where r.anahtar = 'kurum.skrs_kodu'), '')::varchar,
         coalesce(nullif(e.tesis, ''), nullif(ks.tesis_kodu, ''), nullif(k0.tesis_kodu, ''),
                  (select m.kurum_kodu from public.entegrasyon_hesap m
                    where m.kod = 'MEDULA' and btrim(coalesce(m.kurum_kodu, '')) <> ''
                    order by (m.sube_id = p_sube) desc nulls last, m.test_mi nulls last, m.id limit 1), '')::varchar,
         (case when e.id is null then 'kurum profili / eski ayar'
               when e.sube_id is null then 'e-Nabız (kurum geneli)' else 'e-Nabız (şube)' end)::varchar,
         e.id
    from (select 1) z
    left join e on true
    left join public.kurum_profil ks on ks.sube_id = coalesce(p_sube, 0) and coalesce(p_sube, 0) <> 0
    left join public.kurum_profil k0 on k0.sube_id = 0
    left join public.sube sb on sb.id = p_sube
$$;
comment on function public.fn_kurum_kimlik(integer) is
  '1321: şubenin Bakanlık kimliği - ANA kaynak e-Nabız hesabı (kurum_kodu = SKRS, ayarlar.medulaTesisKodu, ayarlar.bakanlikAd; şube satırı → kurum geneli), yoksa kurum profili, yoksa eski yer.';

-- fn_kurum_skrs / fn_kurum_tesis (1318) fn_kurum_kimlik'i çağırır - imza değişmedi, yeniden tanım gerekmez; açıklama güncellenir.
comment on function public.fn_kurum_skrs(integer) is '1321: şubenin SKRS kurum kodu - e-Nabız hesabı → kurum profili → eski yer.';
comment on function public.fn_kurum_tesis(integer) is '1321: şubenin MEDULA tesis kodu - e-Nabız hesabı (ayarlar.medulaTesisKodu) → kurum profili → MEDULA hesabı.';

-- e-Nabız hesabında boş kalan tesis / ad: kurum profilindeki (1317) değerle doldur (yalnız boşsa).
update public.entegrasyon_hesap h
   set ayarlar = coalesce(h.ayarlar, '{}'::jsonb)
                 || case when btrim(coalesce(h.ayarlar ->> 'medulaTesisKodu', '')) = '' and coalesce(kp.tesis_kodu, '') <> ''
                         then jsonb_build_object('medulaTesisKodu', kp.tesis_kodu) else '{}'::jsonb end
                 || case when btrim(coalesce(h.ayarlar ->> 'bakanlikAd', '')) = '' and coalesce(kp.bakanlik_ad, '') <> ''
                         then jsonb_build_object('bakanlikAd', kp.bakanlik_ad) else '{}'::jsonb end
  from public.kurum_profil kp
 where h.kod = 'ENABIZ' and kp.sube_id = coalesce(h.sube_id, 0)
   and ((btrim(coalesce(h.ayarlar ->> 'medulaTesisKodu', '')) = '' and coalesce(kp.tesis_kodu, '') <> '')
     or (btrim(coalesce(h.ayarlar ->> 'bakanlikAd', '')) = '' and coalesce(kp.bakanlik_ad, '') <> ''));

commit;
