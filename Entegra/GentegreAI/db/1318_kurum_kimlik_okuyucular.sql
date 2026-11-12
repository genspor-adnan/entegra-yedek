-- 1318 - Kurum kimliği tek kaynak: e-Nabız ve MEDULA okuyucuları (1317'nin devamı)
--
-- 1317 SKRS kurum kodunu ve MEDULA tesis kodunu kurum profiline (şube bazlı) taşıdı. e-Nabız (ENABIZ hesabının
-- kurum_kodu = SKRS kurum / healthcareProvider) ve MEDULA (MEDULA hesabının kurum_kodu = tesis kodu) okuyucuları bu iki
-- fonksiyondan okur: önce kurum profili (şube → kurum geneli), profil boşsa ESKİ yer - geçişte boş kalan kurulum
-- bozulmaz. Entegrasyon kartındaki "Kurum / Tesis Kodu" alanı bu iki servis için artık bilgi amaçlı.
--
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

create or replace function public.fn_kurum_skrs(p_sube integer)
returns varchar language sql stable as $$
  select coalesce(nullif((select k.skrs from public.fn_kurum_kimlik(p_sube) k), ''),
                  (select e.kurum_kodu from public.entegrasyon_hesap e
                    where e.kod = 'ENABIZ' and e.aktif = 1 and btrim(coalesce(e.kurum_kodu, '')) <> ''
                    order by (e.sube_id = p_sube) desc nulls last, e.test_mi, e.id limit 1), '')::varchar
$$;
comment on function public.fn_kurum_skrs(integer) is '1318: şubenin SKRS kurum kodu - kurum profili, yoksa ENABIZ hesabının kurum kodu (eski yer).';

create or replace function public.fn_kurum_tesis(p_sube integer)
returns varchar language sql stable as $$
  select coalesce(nullif((select k.tesis from public.fn_kurum_kimlik(p_sube) k), ''),
                  (select e.kurum_kodu from public.entegrasyon_hesap e
                    where e.kod = 'MEDULA' and btrim(coalesce(e.kurum_kodu, '')) <> ''
                    order by (e.sube_id = p_sube) desc nulls last, e.test_mi nulls last, e.id limit 1), '')::varchar
$$;
comment on function public.fn_kurum_tesis(integer) is '1318: şubenin MEDULA tesis kodu - kurum profili, yoksa MEDULA hesabının kurum kodu (eski yer).';

commit;
